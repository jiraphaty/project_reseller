#!/bin/bash

clear

#get web
webreseller="`wget -qO- https://raw.githubusercontent.com/jiraphaty/project_reseller/master/web_for_buy?token=AcAlfR_lmnZFr5GSVhMppjBs_GAaodX6ks5cnROdwA%3D%3D`"
echo $webreseller

printf '\t\t#################'
printf ''
read key
