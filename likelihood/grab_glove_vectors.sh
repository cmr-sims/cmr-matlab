#! /bin/bash

# USAGE: first argument is the glove file 
# second argument is the wordpool file
# third argument is the output file
# NOTE: glove vectors will be *appended* to the output file

# After it runs, use the matlab script prep_glove.m to do the rest

echo "hang tight, the script is running!"

# wordpool file must be lowercase to match the glove file 

while read -r line
do
    #echo $line
    grep "^$line " $1 >> $3
    echo -n .
done < $2




