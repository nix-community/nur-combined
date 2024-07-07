#!/bin/sh

usage(){
	echo "Usage: ./mobiledemo [frame|togif] <input_file>"
	echo "The input file can be of any format supported by ffmpeg"
	echo "An overlayed.mp4 file will be generated for the frame action."
	echo "A .gif extension file will be generated for the togif action."
}
frame() {
	scaled=$(mktemp --suff=.mp4)
	scaled_padded=$(mktemp --suff=.mp4)
	maquette="maquette.png"

	# Scale input video to size
	ffmpeg -y -i "$1" \
		-vf scale=1354:2706 \
		-vcodec libx264  \
		-r 15 \
		-preset ultrafast \
		"$scaled"

	# Add padding and center
	ffmpeg -y -i "$scaled" \
		-vf "pad=1588:3512:118:389" \
		-vcodec libx264  \
		-preset ultrafast \
		"$scaled_padded"

	# Overlay the phone frame on top of the video, they should have the same size
	ffmpeg -y -i "$scaled_padded" -i "$maquette" \
		-filter_complex "[0:v][1:v] overlay=0:0:enable='1'" \
		-c:a copy \
		-vcodec libx264  \
		-preset ultrafast \
		overlayed.mp4

	rm -rf "$scaled"
	rm -rf "$scaled_padded"
}

togif() {
	scaled=$(mktemp --suff=.mp4)
	gif=$(mktemp --suff=.gif)
	# Scale input video to size
	ffmpeg -y -i "$1" \
		-vf scale=-2:640 \
		-vcodec libx264  \
		-r 15 \
		-preset ultrafast \
		"$scaled"

	ffmpeg -y -i "$scaled" "$gif"

	gifsicle -O3 --lossy=80 -o "${1%.*}.gif" "$gif"

	rm -rf "$scaled"
	rm -rf "$gif"
}

for i in "$@"
do
case $i in
    -h|--help)
		usage
		exit 0
    ;;
    frame)
		frame "$2"
    ;;
    togif)
		togif "$2"
    ;;
    *)
		exit 0
    ;;
esac
done

if (( $# != 2 )); then
    echo "Illegal number of parameters"
	usage
	exit 1
fi

