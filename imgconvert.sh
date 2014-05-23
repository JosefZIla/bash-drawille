#!/bin/bash
tmpfile=$(mktemp).pgm
outfile=${1%.*}.pgm
convert $1 +repage -resize 100x100 -monochrome -depth 1 -type Bilevel $tmpfile
cat $tmpfile | tr "\000\001" "EF" >$outfile
sed -i -e "s/E/0/g" -e "s/F/1/g" $outfile
echo Written $outfile \($tmpfile\)
