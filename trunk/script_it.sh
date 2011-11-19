ls -lh A/
mkdir -p B/OriginalCaps
cp A/* B/OriginalCaps/
mkdir B/CleanCaps
c=1
for f in A/*
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