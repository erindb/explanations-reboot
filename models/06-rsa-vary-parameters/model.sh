#!/bin/bash

model=$1

for i in `seq 1 6`;
do
	python transform.py $model/lk$i
done
