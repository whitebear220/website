#!/bin/bash
var=`date`
echo $var > out.log
echo "123"
sleep 10
var=`date`
echo $var >> out.log

