#!/usr/bin/env bash
while true; do
  if ping -c 1 114.114.114.114 >/dev/null 2>&1; then
    echo NETWORK OK
    sleep 5s
  else
    echo DRCOMING
    CURRENT_IP=$(ifconfig | grep inet | grep -v inet6 | grep -v 127 | grep -v 192 | awk '{print $(NF-2)}' | cut -d ':' -f2)
  curl -X POST "http://10.168.6.10:801/eportal/?c=ACSetting&a=Login&protocol=http:&hostname=10.168.6.10&iTermType=1&wlanuserip=${CURRENT_IP}&wlanacip=10.168.6.9&mac=00-00-00-00-00-00&ip=${CURRENT_IP}&enAdvert=0&queryACIP=0&loginMethod=1" \
  -H "Connection: keep-alive" \
  -H "Cache-Control: max-age=0" \
  -H "Origin: http://10.168.6.10" \
  -H "Upgrade-Insecure-Requests: 1" \
  -H "DNT: 1" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/85.0.4183.121 Safari/537.36" \
  -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9" \
  -H "Referer: http://10.168.6.10/" \
  -H "Accept-Language: zh-CN,zh;q=0.9" \
  -H "Cookie: program=new; vlan=0; ssid=null; areaID=null; ISP_select=@cmcc; md5_login2=%2C0%2C账号@cmcc%7C密码; ip=${CURRENT_IP}; PHPSESSID=tja4gdsrpd9udd0buvsblaots3" \
  --data-raw "DDDDD=%2C0%2C账号%40cmcc&upass=密码&R1=0&R2=0&R3=0&R6=0&para=00&0MKKey=123456&buttonClicked=&redirect_url=&err_flag=&username=&password=&user=&cmd=&Login=" \
    sleep 5s
  fi
done
