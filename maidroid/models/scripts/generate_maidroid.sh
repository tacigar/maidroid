#/bin/bash

declare -a arr=()
arr[1]='gray92'
arr[2]='gray68'
arr[3]='gray36'
arr[4]='gray17'
arr[5]='blue'
arr[6]='cyan'
arr[7]='green'
arr[8]='DarkGreen'
arr[9]='yellow'
arr[10]='orange'
arr[11]='brown'
arr[12]='red'
arr[13]='pink'
arr[14]='magenta'
arr[15]='violet'

for ((i=1; i<16; i++)); do
  type=$(($i % 3 + 1)) 
  maidroid_type="maidroid_type${type}.png"

  output="../maidroid_maidroid_mk${i}.png"
  color=${arr[i]}
  convert +level-colors $color,White maidroid_hair.png maidroid_hair_tmp.png
  composite maidroid_hair_tmp.png $maidroid_type $output

  rm maidroid_hair_tmp.png
done
