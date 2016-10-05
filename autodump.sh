#!/bin/bash
for profile in $(ls | grep ".bin\|.iso\|.vmem\|.mem\|.raw\|.dd")
do
	volatility -f $profile kdbgscan | grep "Profile suggestion" | awk '{print $NF}' > tempprofs 2> /dev/null
	for possible in $(cat tempprofs)
	do
		if [ -z $(volatility -f $profile --profile=$possible pslist | grep System) ]; then
			echo "no match"
		else
			echo "$profile: $possible" >> current_profiles.txt
			volatility -f $profile --profile=$possible moddump --dump-dir=/root/Downloads/
			volatility -f $profile --profile=$possible psxview | awk '{print $1}' | grep -v "Offset\|-" > tempoffset
			for offset in $(cat tempoffset)
			do
				volatility -f $profile --profile=$possible dlldump -o $offset -m --dump-dir=/root/Downloads/
				volatility -f $profile --profile=$possible procdump -o $offset -m --dump-dir=/root/Downloads/
			done
			break
		fi
	done
done
rm -rf tempprof
