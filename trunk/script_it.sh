#Script_it, a simple script which simply tidy your .cap packets collection and prepare them for cracking with oclHashcat-Plus.
#Concept by Hash-IT
#Code by SmilingWolf
echo "Script_it, a simple script which simply tidy your .cap packets collection and prepare them for cracking with oclHashcat-Plus."
echo "You're free to redistribute this script anywhere you want, but keep the original credits. Thank You."
echo "Concept by Hash-IT"
echo "Code by SmilingWolf"
sleep 3
ls -lh A/*
mkdir -p B/OriginalCaps
cp A/* B/OriginalCaps/
echo "Deleting duplicated packets..."
mkdir B/UniqueCaps
md5sum B/OriginalCaps/* > /tmp/hashes_files.tmp
LIST=`md5sum B/OriginalCaps/* | cut -b -32 | sort | uniq`
for MD5 in $LIST
  do
  ULIST=`grep $MD5 /tmp/hashes_files.tmp | head -1 | cut -b 35-`
  DLIST=`grep $MD5 /tmp/hashes_files.tmp | head -1 | cut -b 35- | cut -b 16-`
  cp "$ULIST" "B/UniqueCaps/$DLIST"
done
rm /tmp/hashes_files.tmp
echo "Done."
echo "Remaining packets:"
ls -lh B/UniqueCaps/*
mkdir B/BadCaps
for f in B/UniqueCaps/*
  do
  l=`wpaclean /dev/null "$f" | wc -l`
  if [ $l == 2 ];
    then
    NewPos=`echo -n "$f" | cut -b 14-`
    echo "Bad capture file found!!! Moving it to B/BadCaps/$NewPos"
    mv "$f" "B/BadCaps/$NewPos"
  fi  
done
mkdir B/ReallyUniqueCaps
for f in B/UniqueCaps/*
  do
  BSSID=`wpaclean /dev/null "$f" | cut -d' ' -f 2 | tail -2 | head -1`
  echo "$BSSID $f">> /tmp/bssids_files.tmp
done
LIST=`cat /tmp/bssids_files.tmp | cut -b -17 | sort | uniq`
for BSSIDS in $LIST
  do
  ULIST=`grep $BSSIDS /tmp/bssids_files.tmp | head -1 | cut -b 19-`
  DLIST=`grep $BSSIDS /tmp/bssids_files.tmp | head -1 | cut -b 19- | cut -b 14-`
  cp "$ULIST" "B/ReallyUniqueCaps/$DLIST"
done
rm /tmp/bssids_files.tmp
mkdir B/CleanCaps
c=1
for f in B/ReallyUniqueCaps/*
  do
  l=`wpaclean /dev/null "$f" | tail -2 | head -1 | cut -b 23-`
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
done
ls -lh B/CleanCaps/*
mkdir B/HCcaps
for f in B/CleanCaps/*
  do
  n=`echo -n "$f" | cut -b 13- | sed s/\ clean\.cap//g`
  aircrack-ng -J "B/HCcaps/$n" "$f"
done
ls -lh B/HCcaps/*