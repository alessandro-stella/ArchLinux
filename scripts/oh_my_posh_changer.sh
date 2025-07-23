#!/bin/bash

colors_file="$HOME/.cache/wallust/colors.json"
template="$HOME/.config/oh-my-posh/themes/themeTemplate.omp.json"
output="$HOME/.config/oh-my-posh/themes/EDM115-newline.omp.json"
lighten_percent=${1:-1}

if [ ! -f "$colors_file" ] || [ ! -f "$template" ]; then
  exit 1
fi

mapfile -t colors < <(jq -r '.[0:16][]' "$colors_file")

if [ "${#colors[@]}" -ne 16 ]; then
  exit 1
fi

lighten_color() {
  hex=${1#"#"}
  percent=$2

  r=$((16#${hex:0:2}))
  g=$((16#${hex:2:2}))
  b=$((16#${hex:4:2}))

  lighten() {
    val=$1
    p=$2
    echo $(( val + ( (255 - val) * p / 100 ) ))
  }

  r=$(lighten $r $percent)
  g=$(lighten $g $percent)
  b=$(lighten $b $percent)

  printf "#%02x%02x%02x" $r $g $b
}

color0_light=$(lighten_color "${colors[0]}" "$lighten_percent")

cp "$template" "$output"

for i in {1..15}; do
  sed -i "s/__COLOR${i}__/${colors[$i]}/g" "$output"
done

sed -i "s/__COLOR0__/$color0_light/g" "$output"
