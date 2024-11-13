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

if [ "$#" != '2' ]; then
	echo "usage: $(basename "$0") operation file"
	echo "operation can be one of: explode pat"
	exit 1
fi

operation="$1"
input="$2"
size="${size:-256}"
output="${output:-"${input%%.*}.gif"}"

size2="${size}x${size}"

case "$operation" in
explode)
	delay=4
	command_line=(
		'(' -clone 0 -implode -0.5 ')'
		'(' -clone 0 -implode -1 ')'
		'(' -clone 0 -implode -1.5 ')'
		'(' -clone 0 -implode -2 ')'
		"${explode}/*.png[$size2]"
	)
	;;
pat)
	delay=6
	command_line=()
	bc_start="scale=6;size=${size};img_scale=0.875;squish=1.25;posx=0.125;posy=0.1786;squish_px=0.4*squish;squish_py=0.9*squish;
define max(a, b) { if (a < b) { return b; } else { return a; } };"
	for (( i=0; i<5; ++i )) do
		case "$i" in
		0) frame="fx=0;       fy=0 ;     fw=0;      fh=0;      " ;;
		1) frame="fx=-0.0357; fy=0.1071; fw=0.0357; fh=-0.1071;" ;;
		2) frame="fx=-0.1071; fy=0.1607; fw=0.1071; fh=-0.1607;" ;;
		3) frame="fx=-0.0714; fy=0.1071; fw=0.0357; fh=-0.1071;" ;;
		4) frame="fx=-0.0375; fy=0;      fw=0;      fh=0;      " ;;
		esac
		posx="$(bc <<<"$bc_start$frame value= (posx + fx * squish_px) * size;scale=0;value/1")"
		posy="$(bc <<<"$bc_start$frame value= (posy + fy * squish_py) * size;scale=0;value/1")"
		sizex="$(bc <<<"$bc_start$frame value= (1 + fw * squish) * size * img_scale;scale=0;value/1")"
		sizey="$(bc <<<"$bc_start$frame value= (1 + fh * squish) * size * img_scale;scale=0;value/1")"
		offset="$(bc <<<"scale=0; 112*$i")"
		paty="$(bc <<<"$bc_start$frame value= max(0, $posy * 0.75 - max(0, posy * size) - 0.5);scale=0;value/1")"
		command_line+=(
			'('
			-size "${size2}" null:
			-clone 0 -geometry "${sizex}x${sizey}!+${posx}+${posy}" -composite
			"${pat}[112x112+$offset+0]" -geometry "${size2}+0+${paty}" -composite
			')'
		)
	done
	command_line+=(-delete 0)
	;;
*)
	echo "invalid operation: $operation"
	exit 1
	;;
esac

magick -delay "$delay" -dispose previous -background none "$input" -scale "$size2" \
	"${command_line[@]}" \
	\( -clone 0--1 -background none -append -colors 128 -unique-colors -write mpr:colormap +delete \) -fuzz 2% -remap mpr:colormap \
	-layers coalesce -layers optimize-plus -layers optimize-transparency \
	-loop 0 "$output"
