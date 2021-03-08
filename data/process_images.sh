#!/bin/bash -xe

DATASET=${1:-'train'}
CLASSES=${2:-'ER NR'}

for value in $CLASSES
do
  if [ $DATASET == 'train' ] 
  then
    path="$(echo "$DATASET/$value")"
  else
    path="$(echo "$DATASET")"
  fi

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

    if [ $DATASET == 'train' ]
    then
      # extracting angle from file name
      angle=$(echo "$i" | cut --only-delimited -d '_' -f 1)

      # extracting energy of the particle (keV) from file name
      if [ $value == 'ER' ]
      then
        energy=$(echo "$i" | cut --only-delimited -d '_' -f 7)
      else
        energy=$(echo "$i" | cut --only-delimited -d '_' -f 8)
      fi

      # concatenate infos and append .csv
      echo "$angle,$value,$energy,$pixels"

    else
      echo "$pixels"
    fi

  done >> $DATASET"_dataset.csv"

done

zip "./"$DATASET"_dataset.zip" $DATASET"_dataset.csv"
