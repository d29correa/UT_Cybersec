#1/bin/bash

if [ $3 = "Roulette" ];  then 

cat $1 | awk '{print $1, $2, $5, $6}'| grep "$2"

fi

if [ $3 =  "Blackjack" ]; then

cat $1 | awk '{print $1, $2, $3, $4}'| grep "$2"

fi

if [ $3 = "Texas" ]; then

cat $1 | awk '{print $1, $2, $7, $8}'| grep "$2"

fi
