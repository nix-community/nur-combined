if [ "$1" == "" ]
then
	num=0
else
	num=$1
fi
cat chords-en.conf | grep -v "^#" | awk -F = '{print $2}' | tr "\n" " "
