while true; do
	case "$1" in
	-o | --output)
		output="$2"
		shift
		shift
		;;
	-s | --size)
		size="$2"
		shift
		shift
		;;
	-*)
		echo "unknown argument: $1"
		exit 1
		;;
	*)
		break
		;;
	esac
done

if [ "$#" != '1' ]; then
	echo "usage: $(basename "$0") file"
	exit 1
fi

size="${size:-256}"
output="${output:-"${1%%.*}.gif"}"

size="${size}x${size}"

magick -delay 4 "$1" \
	-scale "$size" \
	\( -clone 0 -implode -0.5 \) \
	\( -clone 0 -implode -1 \) \
	\( -clone 0 -implode -1.5 \) \
	\( -clone 0 -implode -2 \) \
	"${explode}/*.png[$size]" \
	\( -clone 0--1 -background none -append -colors 128 -unique-colors -write mpr:colormap +delete \) -fuzz 2% -remap mpr:colormap \
	-layers coalesce -layers optimize-plus -layers optimize-transparency \
	-loop 0 "$output"
