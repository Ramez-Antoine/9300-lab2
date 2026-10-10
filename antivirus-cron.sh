#!/bin/bash

base="$(cd "$(dirname "$0")" && pwd)"
dir="$base/watched"
malicious_dir="$base/quarantine"
whitelist="$base/whitelist.txt"
last="$base/directory-info.cron.last"
new="$base/directory-info.cron.new"

if [ ! -d "$dir" ]; then
    echo "Directory does not exist"
    exit 1
fi

mkdir -p "$malicious_dir" || exit 1
touch "$whitelist" || exit 1

shopt -s nullglob dotglob

scan_files() {
    for file in "$dir"/*
    do
        [ -f "$file" ] || continue

        filename="${file##*/}"

        if grep -Fxq -- "$filename" "$whitelist"; then
            continue
        fi

        malicious=0

        case "$file" in
            *.exe|*.bat|*.vbs|*.scr|*.ps1)
                malicious=1
                ;;
            *)
                if grep -Eqi "virus|trojan|malware|worm|ransomware" "$file"; then
                    malicious=1
                fi
                ;;
        esac

        if [ "$malicious" -eq 1 ]; then
            if cp -- "$file" "$malicious_dir/" && rm -- "$file"; then
                echo "$file is malicious and it is DELETED"
            fi
        fi
    done
}

if [ ! -f "$last" ]; then
    scan_files
    ls -l "$dir" > "$last"
else
    ls -l "$dir" > "$new" || exit 1
    cmp -s "$last" "$new"
    status=$?

    if [ "$status" -eq 1 ]; then
        scan_files
        ls -l "$dir" > "$last"
    elif [ "$status" -ne 0 ]; then
        echo "Snapshot comparison failed"
        exit 1
    fi
fi
