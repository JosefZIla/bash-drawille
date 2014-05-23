#!/bin/bash
. drawille.sh

function engine_init {
  canvas_init 130 130
  let "sa=63, sb=3, sc=63, sd=63"
  canvas_line 0 0 0 130
  canvas_line 0 130 130 130
  canvas_line 130 130 130 0
  canvas_line 130 0 0 0
  canvas_display_pgm arch.pgm 15 15
}

engine_init
tput cup 0 0
canvas_draw
