#!/bin/bash
declare -a variablesets=("A B" "A B C" "A B C" "A B C D" "A B C D" "A B C")
declare -a variablestates=("T T" "T T T" "T T F" "F F F F" "T T T T" "F F T")
for i in {1..6}
do
	variableset=( ${variablesets[$i-1]} )
	variablestateset=( ${variablestates[$i-1]} )
	n=${#variableset[@]}
	for i1 in $(seq 1 $n)
	do
		v1=${variableset[$i1-1]}
		s1=${variablestateset[$i1-1]}
		for i2 in $(seq 1 $n)
		do
			v2=${variableset[$i2-1]}
			s2=${variablestateset[$i2-1]}
			if [ $v1 != $v2 ]
				then
				program_file="one-link-per-utterance/lk$i$v1$v2/autoexpanded.wppl"
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
				cat $program_file > tmp.wppl
				echo "var rs = Infer({method:'enumerate'}, s2({ lexicon: 'none', actualUtterance: '"$utterance"' }))" >> tmp.wppl
				echo "Math.exp(rs.score('"$utterance"'))" >> tmp.wppl
				webppl tmp.wppl > $output_file
			fi
		done
	done
done