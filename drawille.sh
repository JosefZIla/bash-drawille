declare -ia pixel_map=( 1 8 2 16 4 32 64 128 )
declare -a pixel_buffer

function canvas_init {
  export term_height=$(tput lines)
  export term_width=$(tput cols)
  let $#==2 && {
    let term_width=$1/2+2
    let term_height=$2/4+2
  }
  let "canvas_height=4*(--term_height)"
  let "canvas_width=2*(--term_width)"
  export canvas_height
  export canvas_width
  canvas_clear
}

function canvas_get {
  let "$1>=canvas_width" && return
  let "$2>=canvas_height" && return
  ((
    xcoord=$1/2,
    xoff=$1%2,
    ycoord=$2/4,
    yoff=$2%4,
    char=pixel_buffer[ycoord*term_width+xcoord],
    mask=pixel_map[yoff*2+xoff],
    REPLY=char&mask?1:0
  ))
}

function canvas_set {
  let "$1>=canvas_width" && return
  let "$2>=canvas_height" && return
  ((
    xcoord=$1/2,
    xoff=$1%2,
    ycoord=$2/4,
    yoff=$2%4,
    mask=pixel_map[yoff*2+xoff],
    pixel_buffer[ycoord*term_width+xcoord]|=mask
  ))
}

function canvas_unset {
  let "$1>=canvas_width" && return
  let "$2>=canvas_height" && return
  ((
    xcoord=$1/2,
    xoff=$1%2,
    ycoord=$2/4,
    yoff=$2%4,
    mask=255-pixel_map[yoff*2+xoff],
    pixel_buffer[ycoord*term_width+xcoord]&=mask
  ))
}

function canvas_draw {
  unset buffer
  let  i=0
  while let "i<term_height"; do
    let j=0
    while let "j<term_width"; do
      printf -v charcode "28%02x" ${pixel_buffer[i*term_width+j++]}
      buffer+="\u$charcode"
    done
    buffer+="\n"
    let i++
  done
  printf $buffer
}

function canvas_clear {
  unset pixel_buffer
  declare -a pixel_buffer
}

function canvas_line {
  ((
    xdir=($3-$1)>=0?1:-1,
    ydir=($4-$2)>=0?1:-1,
    dx=xdir>0?$3-$1:$1-$3,
    dy=ydir>0?$4-$2:$2-$4,
    dir=dx>dy?1:0,
    d=dir?dy+dy-dx:dx+dx-dy,
    y=dir?$2:$2+ydir,
    x=dir?$1+xdir:$1,
    loop=0,
    limit=dir?dx:dy
  ))
  [[ -z "$5" ]] && canvas_set $x $y || canvas_unset $x $y
  while let "loop++<$limit"; do
    if [ $d -gt 0 ]; then
      if [ $dir == 1 ]; then
        let y+=ydir
      else
        let x+=xdir
      fi 
      [[ -z "$5" ]] && canvas_set $x $y || canvas_unset $x $y
      let d+=dir?dy+dy-dx-dx:dx+dx-dy-dy
    else
      [[ -z "$5" ]] && canvas_set $x $y || canvas_unset $x $y
      let d+=dir?dy+dy:dx+dx
    fi
    if [ $dir == 1 ]; then
      let x+=xdir
    else
      let y+=ydir
    fi 
  done
}

# https://www.geeksforgeeks.org/bresenhams-circle-drawing-algorithm/
function canvas_circle { # x_center,y_center,radius
  function draw_circle_octant() { # x_center, y_center, x, y
    [[ -z "$5" ]] && draw="canvas_set" || draw="canvas_unset"
    $draw $(($1+$3)) $(($2+$4))
    $draw $(($1-$3)) $(($2+$4))
    $draw $(($1+$3)) $(($2-$4))
    $draw $(($1-$3)) $(($2-$4))
    $draw $(($1+$4)) $(($2+$3))
    $draw $(($1-$4)) $(($2+$3))
    $draw $(($1+$4)) $(($2-$3))
    $draw $(($1-$4)) $(($2-$3))
  }
  ((
    x=0,
    y=$3,
    d=3-2*$3
  ))
  while ((y>=x)); do
    if ((d>0)); then
      ((
        y--,
        d=d+4*(x-y)+10
      ))
    else
        let d=d+4*x+6
    fi
    let x++
    draw_circle_octant $1 $2 $x $y $4
  done
}

function canvas_display_pgm {
  exec 3<$1
  read magic <&3
  read resx resy <&3
  read scale <&3
  let ix=0,iy=0,ox=0,oy=0
  let $#==3 && {
    let ox=$2
    let oy=$3
  }
  while read -N1; do
    let ix==resx && {
      let ix=0,iy++
    }
    if let REPLY==1; then
      let dx=ix+ox
      let dy=iy+oy
      canvas_set $dx $dy
    fi
    let ix++
  done <&3
  exec 3>&-
}
