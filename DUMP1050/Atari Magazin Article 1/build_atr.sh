#!/bin/bash

if [ ! -d /tmp/atr ];
then
	mkdir /tmp/atr
else
	rm -rf /tmp/atr/*
fi

cp ../DOS.SYS /tmp/atr/
cp ../DUP.SYS /tmp/atr/

cp /tmp/listing_1.xex /tmp/atr/LISTING1.EXE
cp /tmp/listing_2.xex /tmp/atr/LISTING2.EXE
cp /tmp/listing_3.xex /tmp/atr/LISTING3.EXE

dir2atr -b Dos25 720 /tmp/AM_ART1.atr /tmp/atr/

