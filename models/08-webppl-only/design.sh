#!/bin/bash
declare -a variablesets=("A B" "A B C" "A B C" "A B C D" "A B C D" "A B C")
declare -a variablestatesets=("T T" "T T T" "T T F" "F F F F" "T T T T" "F F T")
touch design.txt
for i in {1..6}
do
	variableset=( ${variablesets[$i-1]} )
	variablestateset=( ${variablestatesets[$i-1]} )
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
				echo $i $v1 $s1 $v2 $s2 >> design.txt
			fi
		done
	done
done