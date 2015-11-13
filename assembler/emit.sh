#!/bin/sh

if [ "$1" = "" ]; then
	echo "usage : sh $0 [assembly-name]"
else
	IFS=$'\n'
	BAK="$1~"
	PC=0
	mv "$1" $BAK
	for l in $(cat $BAK); do
		if [ -n "$(echo $l | grep .text)" ] \
		  || [ -n "$(echo $l | grep .data)" ] \
		  || [ -n "$(echo $l | grep .globl)" ] \
		  || [ -n "$(echo $l | grep .long)" ] \
		  || [ -n "$(echo $l | grep :)" ] \
		  || [ "$(echo "$l" | tr -d '\t' | tr -d ' ' | cut -c1-1)" = "#" ]; then
			echo $l >> $1
		else
			echo "$l  # $PC" >> $1
			PC=$(expr $PC + 1)
		fi
	done
fi
