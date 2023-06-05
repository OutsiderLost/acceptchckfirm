#!/bin/bash

[ -f "$1" ] && [ -n "$(echo "$1" | sed '/\.bin$/!d')" ] || echo -e '\nuse -> .\scrpt <firmware.bin>\n'
[ -f "$1" ] && [ -n "$(echo "$1" | sed '/\.bin$/!d')" ] || exit
v_INFIRM1="$1"
v_INFIRM="$(dirname "$1")/_$(basename "$1").extracted"
[ -d "$v_INFIRM" ] && rm -rf "$v_INFIRM"

binwalk -e "$v_INFIRM1" | tee binwlog.txt
[ -n "$(cat binwlog.txt)" ] || binwalk -e "$v_INFIRM1" --run-as=root | tee binwlog.txt
v_imgname="$(sed '/Squashfs.*.created/!d;s/.*0x//g;s/[ \t].*//g' binwlog.txt)" # (squashfs filename)
# v_comp="$(sed '/Squashfs.*.created/!d;s/.*compression://g;s/,.*//g' binwlog.txt)" # (e.g.: lzma, xz)

filechck="$(file "$v_INFIRM"/squashfs-root/dev/*  | awk '{print $2}' | sed '/char[a-z]/!d;/empty/d;/^[[:space:]]*$/d' | sort -u)"
lschch1="$(ls -l "$v_INFIRM"/squashfs-root/dev/* | awk '{print $5}' | sed '/[1-9],/!d;/^[[:space:]]*$/d' | sort -u)"
lschck2="$(ls -l "$v_INFIRM"/squashfs-root/dev/* | awk '{print $6}' | sed '/[1-9]/!d;/^[[:space:]]*$/d' | sort -u)"

# file check
echo -e '\n[*] file check:\n'
[ -n "$filechck" ] || echo -e '[!] This value empty! something ERROR!\n'
file "$v_INFIRM"/squashfs-root/dev/*  | awk '{print $2}' | sed '/char[a-z]/!d;/empty/d;/^[[:space:]]*$/d' | sort -u
# id number check
echo -e '\n[*] ls id number check:\n'
[ -n "$lschch1" ] || echo -e '[!] This value empty! something ERROR!\n'
ls -l "$v_INFIRM"/squashfs-root/dev/* | awk '{print $5}' | sed '/[1-9],/!d;/^[[:space:]]*$/d' | sort -u
# number check
echo -e '\n[*] ls number check:\n'
[ -n "$lschck2" ] || echo -e '[!] This value empty! something ERROR!\n'
ls -l "$v_INFIRM"/squashfs-root/dev/* | awk '{print $6}' | sed '/[1-9]/!d;/^[[:space:]]*$/d' | sort -u


if [ -n "$filechck" ] && [ -n "$lschch1" ] && [ -n "$lschck2" ]; then
  echo -e '\n[!] All dev filesystem ok! :-)\n'
else
  echo -e '\n[!] One of the values is ERROR! Do not use this firmware!!!\n'
fi
