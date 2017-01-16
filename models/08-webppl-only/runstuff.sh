# 44 lines

n=$1
line=`head -$n design.txt | tail -1`
bash runmodel.sh $line
