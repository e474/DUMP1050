#!/bin/bash

if [ ! -d /tmp/atr ];
then
	mkdir /tmp/atr
else
	rm -rf /tmp/atr/*
fi

cp ./DOS.SYS /tmp/atr/
cp ./DUP.SYS /tmp/atr/
cp /tmp/DUMP1050.xex /tmp/atr/DUMP1050.EXE

dir2atr -b Dos25 720 /tmp/dump1050.atr /tmp/atr/

