#!/bin/bash
. drawille.sh

canvas_init 130 130
let i=j=0
while let "i<=130"; do
  let j=0
  while let "j<=130"; do
    canvas_set $i $j
    let j++
  done
  let i++
done

canvas_circle 65 65 30 1
canvas_draw

