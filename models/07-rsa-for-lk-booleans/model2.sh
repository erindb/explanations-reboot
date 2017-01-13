#!/bin/bash

model=$1

for i in `seq 1 6`;
do
	for variable in "A" "B" "C" "D";
	do
		python transform.py $model/lk$i$variable
	done
done
