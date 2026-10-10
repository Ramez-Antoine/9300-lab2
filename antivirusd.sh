#!/bin/bash
dir="$1"
malicious_dir="$2"
interval="$3"

script_dir="$(cd "$(dirname "0")" && pwd)"
whitelist="$script_dir/whitelist.txt"
touch "$whitelist"
shopt -s nullglob dotglob

echo "Directory: $dir"
echo "Malicious directory: $malicious_dir"
echo "Interval: $interval"
scan_files(){
for file in "$dir"/*
do
	echo "Checking $file"

	filename="${file##*/}"
	if grep -Fxq -- "$filename" "$whitelist"
	then
		echo "$filename is whitelisted"
		continue
	fi

	case "$file" in
        *.exe|*.bat|*.vbs|*.scr|*.ps1)
		cp -- "$file" "$malicious_dir" && rm -- "$file" && echo "$file is malicious and it is DELETED"
	        ;;
        *)
                if grep -Eqi "virus|trojan|malware|worm|ransomware" "$file"
		then
			cp -- "$file" "$malicious_dir" && rm -- "$file" && echo "$file is malicious and it is DELETED"
		else
			echo "Safe file"
		fi
        ;;
esac
done
}

scan_files
ls -l $dir > directory-info.last

while true
do
	sleep $interval
	ls -l $dir > directory-info.new
	echo "Checking for changes"
	if cmp -s directory-info.last directory-info.new
	then
		echo "No changes"
	else
		scan_files
		ls -l $dir > directory-info.last
	fi
done
