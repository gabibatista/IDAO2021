#!/bin/bash -xe

DATASET=${1:-'train'}
CLASSES=${2:-'ER NR'}

for value in $CLASSES
do
  path="$(echo "$DATASET/$value")"
  for image in "$path"/*.png
  do
    i=${image##*/}
    i=${i%.*}
  
    # resizing to 50x50
    convert "$image" -resize 50x50\! -quality 100 "$path/resized/$i.png";
  
    # converting to .txt
    convert "$path/resized/$i.png" "$path/rgb/$i.txt"

    # extracting value from each pixel
    pixels=''
    while read line; do
      pixels+="$(echo "$line" | cut --only-delimited -d '(' -f 2 | cut -d ',' -f 1),";
    done < "$path/rgb/$i.txt"
    pixels="${pixels:1:${#pixels}-2}" # removing first and last characters (,)

    # extracting angle from file name
    angle=$(echo "$i" | cut -d '_' -f 1)

    # extracting class (ER or NR) from file name
    class=$(echo "$i" | cut -d '_' -f 6)

    # extracting energy of the particle (keV) from file name
    energy=$(echo "$i" | cut -d '_' -f 7)

    # concatenate all infos to append .csv
    echo "$angle,$class,$energy,[$pixels]"
  done >> dataset.csv
done
