#!/bin/bash
i=$1
v1=$2
s1=$3
v2=$4
s2=$5

declare -a variablesets=("A B" "A B C" "A B C" "A B C D" "A B C D" "A B C")
declare -a variablestates=("T T" "T T T" "T T F" "F F F F" "T T T T" "F F T")

variableset=( ${variablesets[$i-1]} )
variablestateset=( ${variablestates[$i-1]} )

program_file="one-link-per-utterance/lk$i$v1$v2/autoexpanded.wppl"
tmp_file="tmp/lk$i$v1$v2.wppl"
output_file="results/lk$i$v1$v2"

if [ s1 == "F" ]; then
   x1="! "
else
   x1=""
fi
explanandum=$x1$v1
if [ s2 == "F" ]; then
   x2="! "
else
   x2=""
fi
explanans=$x2$v2

utterance=$explanandum" because "$explanans
echo $program_file
echo $output_file
echo $utterance
cat $program_file > $tmp_file
echo "var rs = Infer({method:'enumerate'}, s2({ lexicon: 'none', utteranceSet: 'even_more', actualUtterance: '"$utterance"' }))" >> $tmp_file
echo "Math.exp(rs.score('"$utterance"'))" >> $tmp_file
webppl $tmp_file > $output_file
