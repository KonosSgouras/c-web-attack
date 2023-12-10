#!/bin/bash

str=$(tail -c 400 kostas |  head -c 320)
#echo $str

substr="0x"
 
prefix=${str%%$substr*}
index=${#prefix}
echo $str
canari=${str:index+221:10}
echo $canari
addr1=${str:index+232:10}
echo $addr1

addr2=${str:index+243:10}
echo $addr2
