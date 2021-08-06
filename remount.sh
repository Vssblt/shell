#!/bin/bash

sleep 180

i=0

DEFAULT_IFS=$IFS
IFS=$'\n'

declare -a items=()


while read line
do    
  result=`echo $line | grep -e "^[[:blank:]]*#" `
  if [ "a$result" != "a" ]; then
    continue
  fi

	line=${line%%#*}

  items[$i]=$line
  
  i=`expr $i + 1`
done < /etc/fstab

while [ 1 ];
do
	# 遍历所有挂载
  for item in ${items[@]}
  do
		IFS=$DEFAULT_IFS

		# 初始化挂载参数值为数组
		declare -a words=()
		j=0
		for word in ${item[@]}
		do
			words[$j]=$word
			j=`expr $j + 1`
		done

		# 声明参数值和参数选项
		mdevice=
		mpath=
		mtype=
		moption=
		mdump=
		mpass=


		if [ ${#words[*]} -ne 6 ]; then
			continue
		fi

		is_exist=`df | grep -e "[[:blank:]]${words[1]}[[:blank:]]*$"`
		if [ "a$is_exist" == "a" ] && [ "a${words[0]}" != "anone" ]; then
			is_uuid=`echo ${words[0]} | grep UUID=`
			if [ "a$is_uuid" != "a" ]; then
				mdevice="-U ${words[0]#UUID=}"
			else
				mdevice="${words[0]}"
			fi
			mpath="${words[1]}"
			mtype="-t ${words[2]}"
			moption="-o ${words[3]}"
			sudo bash -c "echo \"/*************************************************/\" >>/var/log/remount.log"
			sudo bash -c "echo \"Warning! Device detach! Date: `date`. Try to remount! df output:\" >>/var/log/remount.log"
			sudo bash -c "echo \"/-------------------------------------------------/\" >>/var/log/remount.log"
			sudo bash -c "df >>/var/log/remount.log"
			sudo bash -c "echo \"/-------------------------------------------------/\" >>/var/log/remount.log"
			sudo bash -c "echo \"mount $mdevice $mpath $mtype $moption $mdump $mpass\" >>/var/log/remount.log"
			sudo bash -c "echo \"/*************************************************/\" >>/var/log/remount.log"
			mount $mdevice $mpath $mtype $moption $mdump $mpass >>/var/log/remount.log
		fi

		IFS=$'\n'
  done
	sleep 2 
done

