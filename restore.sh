#!/bin/bash
if [ "$#" -ne 2 ]
then
	echo "Usage: $0 dir malicious_dir"
	exit 1
fi

dir="$1"
malicious_dir="$2"

script_dir="$(cd "$(dirname "$0")" && pwd)"
whitelist="$script_dir/whitelist.txt"
touch "$whitelist"

if [ ! -d "$dir" ] || [ ! -d "$malicious_dir" ]
then
	echo "Directory does not exist"
	exit 1
fi 

shopt -s nullglob dotglob

while true
do
	files=("$malicious_dir"/*)

	if [ "${#files[@]}" -eq 0 ]
	then
		echo "No malicious files to review"
		break
	fi

	echo "Malicious files:"

	for i in "${!files[@]}"
	do
		echo "$((i+1))) ${files[i]##*/}"
	done
	read -r -p "Choose a number: " number

	if ! [[ "$number" =~ ^[1-9][0-9]*$ ]] || [ "$number" -gt "${#files[@]}" ]
	then
		echo "Invalid number"
		continue
	fi

	selected="${files[number-1]}"
	filename="${selected##*/}"



	echo "Selected file: $filename"
	echo "1) Restore file"
	echo "2) Permanently delete file"
	echo "3) Leave file and return to list"

	read -r -p "Choose an option: " choice

	case "$choice" in
		1)
			if [ -e "$dir/$filename" ];then
				echo "Cannot restore: file already exists in $dir."
			elif mv -- "$selected" "$dir/";then
				echo "$filename" >> "$whitelist"
				echo "Restored $filename to $dir."
			else echo "Failed to restore $filename."
			fi
			;;
		2)
			if rm -- "$selected";then
				echo "$filename permanently deleted."
			else echo "Failed to delete $filename"
			fi
			;;
		3)
			echo "Leaving $filename in quarantine."
			;;
		*)
			echo "Invalid option"
			;;
	esac
done
