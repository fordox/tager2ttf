#!/usr/bin/bash
for j in Regular Italics Bold Underline
do
	for i in `ls ./PNG`
	do
		#echo "./PNG/$i"		
		perl ./tagerpng2ttf.perl ./PNG/$i $j
	done
done



