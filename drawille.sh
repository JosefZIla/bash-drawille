#!/bin/bash
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
  ((
    xcoord=$1%2?$1/2:$1/2,
    xoff=($1)%2,
    ycoord=$2%4?$2/4:$2/4,
    yoff=($2)%4,
    char=pixel_buffer[ycoord*term_width+xcoord],
    mask=pixel_map[yoff*2+xoff],
    REPLY=char&mask?1:0
  ))
}

function canvas_set {
  ((
    xcoord=$1%2?$1/2:$1/2,
    xoff=($1)%2,
    ycoord=$2%4?$2/4:$2/4,
    yoff=($2)%4,
    mask=pixel_map[yoff*2+xoff],
    pixel_buffer[ycoord*term_width+xcoord]|=mask
  ))
}

function canvas_draw {
  let  i=0
  while let "i<term_height"; do
    let j=0
    while let "j<term_width"; do
      printf -v charcode "28%02x" ${pixel_buffer[i*term_width+j++]}
      printf "\u$charcode"
    done
    printf "\n"
    let i++
  done
}

function canvas_clear {
  unset pixel_buffer
  declare -a pixel_buffer
}

function canvas_line {
  ((
    dx=$3-$1,
    dy=$4-$2,
    d=2*dy-dx,
    y=$2,
    x=$1+1
  ))
  canvas_set $1 $2
  while let "x<=$3"; do
    if let d>0; then
      let y++
      canvas_set $x $y
      let d+=2*dy-2*dx
    else
      canvas_set $x $y
      let d+=2*dy
    fi
    let x++
  done
}

function display_pgm {
  exec 3<$1
  read magic <&3
  read resx resy <&3
  read scale <&3
  let ix=0,iy=0
  while read -N3; do
    let ix==resx && {
      let ix=0,iy++
    }
    if let REPLY==111; then
      canvas_set ix iy
    fi
    let ix++
  done <&3
  exec 3>&-
}
