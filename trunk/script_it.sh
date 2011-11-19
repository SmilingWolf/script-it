#Script_it, a simple script which simply tidy your .cap packets collection and prepare them for cracking with oclHashcat-Plus.
#You're free to redistribute this script anywhere you want, but keep the original credits. Thank You.
#Concept by Hash-IT
#Code by SmilingWolf
#You're using the v1.0 of Script_it, codename Strike Of The Ninja
echo "Script_it, a simple script which simply tidy your .cap packets collection and prepare them for cracking with oclHashcat-Plus."
echo "You're free to redistribute this script anywhere you want, but keep the original credits. Thank You."
echo "Concept by Hash-IT"
echo "Code by SmilingWolf"
echo "You're using the v1.0 of Script_it, codename Strike Of The Ninja"
sleep 3
mkdir -p B/OriginalCaps
OriginalCaps=0
for f in A/*.cap
do
CorrectString=`file "$f" | grep -o "tcpdump capture file"`
  if [ "$CorrectString" == 'tcpdump capture file' ];
  then
    cp "$f" B/OriginalCaps/
    OriginalCaps=$(($OriginalCaps + 1))
  fi
done
echo "Deleting duplicated packets..."
mkdir B/UniqueCaps
md5sum B/OriginalCaps/* > /tmp/hashes_files.tmp
LIST=`md5sum B/OriginalCaps/* | cut -d ' ' -f 1 | sort | uniq`
for MD5 in $LIST
  do
  ULIST=`grep $MD5 /tmp/hashes_files.tmp | head -1 | cut -d ' ' -f 3-`
  cp "$ULIST" B/UniqueCaps/
done
rm /tmp/hashes_files.tmp
echo "Done."
mkdir B/BadCaps
BadCaps=0
for f in B/UniqueCaps/*
  do
  l=`wpaclean /dev/null "$f" | wc -l`
  if [ $l == 2 ];
    then
    NewPos=`echo -n "$f" | cut -b 14-`
    echo "Bad capture file found!!! Moving it to B/BadCaps/$NewPos"
    mv "$f" B/BadCaps/
    BadCaps=$(($BadCaps + 1))
  fi  
done
mkdir B/ReallyUniqueCaps
UniqueCaps=0
for f in B/UniqueCaps/*
  do
  BSSID=`wpaclean /dev/null "$f" | cut -d ' ' -f 2 | tail -2 | head -1`
  echo "$BSSID $f">> /tmp/bssids_files.tmp
done
LIST=`cat /tmp/bssids_files.tmp | cut -d ' ' -f 1 | sort | uniq`
for BSSIDS in $LIST
  do
  ULIST=`grep $BSSIDS /tmp/bssids_files.tmp | head -1 | cut -d ' ' -f 2-`
  cp "$ULIST" B/ReallyUniqueCaps/
  UniqueCaps=$(($UniqueCaps + 1 ))
done
rm /tmp/bssids_files.tmp
mkdir B/CleanCaps
CleanCaps=0
c=1
for f in B/ReallyUniqueCaps/*
  do
  l=`wpaclean /dev/null "$f" | tail -2 | head -1 | cut -d ' ' -f 3-`
  if [ -e "B/CleanCaps/$l clean.cap" ];
    then
    if [ -e "B/CleanCaps/$l ($c) clean.cap" ];
      then
      c=$(( $c + 1 ))
      else
      wpaclean "B/CleanCaps/$l ($c) clean.cap" "$f"
    fi
    else
    wpaclean "B/CleanCaps/$l clean.cap" "$f"
    c=1
  fi
  CleanCaps=$(($CleanCaps + 1))
done
mkdir B/HCcaps
HCcaps=0
for f in B/CleanCaps/*
  do
  n=`echo -n "$f" | cut -b 13- | sed s/\ clean\.cap//g`
  aircrack-ng -J "B/HCcaps/$n" "$f" >> /dev/null
  echo "Converting $f to B/HCcaps/$n.hccap"
  HCcaps=$(($HCcaps + 1))
done
echo ""
echo ""
echo "Report Time!"
echo "Starting number of .cap files: $OriginalCaps"
echo "They are in B/OriginalCaps"
echo "Corrupted Caps found: $BadCaps"
echo "They are in B/BadCaps"
echo "Unique Caps found: $UniqueCaps"
echo "They are in B/ReallyUniqueCaps"
echo "Clean Caps obtained: $CleanCaps"
echo "They are in B/CleanCaps"
echo "Caps converted to HCcaps: $HCcaps"
echo "They are in B/HCcaps"