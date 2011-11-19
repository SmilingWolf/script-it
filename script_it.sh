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
echo "Done."
echo "Remaining packets:"
ls -lh B/UniqueCaps/*
mkdir B/CleanCaps
c=1
for f in B/UniqueCaps/*
do
l=`wpaclean /dev/null "$f" | tail -2 | head -1 | cut -b 23-`
wpaclean "B/CleanCaps/$l ($c) clean.cap" "$f"
c=$(( $c + 1 ))
done
ls -lh B/CleanCaps/*
mkdir B/HCcaps
for f in B/CleanCaps/*
do
n=`echo -n "$f" | cut -b 13- | sed s/\ clean\.cap//g`
aircrack-ng -J "B/HCcaps/$n" "$f"
done
ls -lh B/HCcaps/*