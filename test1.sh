#!/bin/bash
. drawille.sh

function engine_init {
  canvas_init 130 130
  let "sa=63, sb=3, sc=63, sd=63"
  canvas_line 0 0 0 130
  canvas_line 0 130 130 130
  canvas_line 130 130 130 0
  canvas_line 130 0 0 0
  let mode=1
}

function update_view {
  case $mode in
    1)
      let sb+=3
      let sc+=3
      let sb==63 && mode=2
      ;;
    2)
      let sb+=3
      let sc-=3
      let sc==63 && mode=3
      ;;
    3)
      let sb-=3
      let sc-=3
      let sb==63 && mode=4
      ;;
    4)
      let sb-=3
      let sc+=3
      let sc==63 && mode=5
      ;;
    5)
      let sb+=3
      let sc+=3
      let sb==63 && mode=6
      ;;
    6)
      let sb+=3
      let sc-=3
      let sc==63 && mode=7
      ;;
    7)
      let sb-=3
      let sc-=3
      let sb==63 && mode=8
      ;;
    8)
      let sb-=3
      let sc+=3
      let sc==63 && mode=9
      ;;
    9)
      exit 0
      ;;
  esac
  [[ $mode -lt 5 ]] && canvas_line $sa $sb $sc $sd || canvas_line $sa $sb $sc $sd 1
}

function engine_run {
  while true; do
  update_view
  tput cup 0 0
  canvas_draw
#  sleep 0.02
  done
}

engine_init
engine_run

