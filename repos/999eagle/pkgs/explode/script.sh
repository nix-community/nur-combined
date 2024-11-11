if [ "$#" != '1' ]; then
	echo "usage: $(basename "$0") file"
	exit 1
fi

magick -delay 4 "$1" \
	-scale 128x128 \
	\( -clone 0 -implode -0.5 \) \
	\( -clone 0 -implode -1 \) \
	\( -clone 0 -implode -1.5 \) \
	\( -clone 0 -implode -2 \) \
	"${explode}/explode.gif[128x128]" \
	\( -clone 0--1 -background none -append -colors 128 -unique-colors -write mpr:colormap +delete \) -coalesce -fuzz 2% -remap mpr:colormap -layers optimize \
	-loop 0 out.gif
