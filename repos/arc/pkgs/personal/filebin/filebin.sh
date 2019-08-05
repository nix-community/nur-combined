#!/bin/bash
set -eu

# config defaults
FILEBIN_BOXCAR_KEY=
FILEBIN_S3_BUCKET=
FILEBIN_S3_CLASS=ONEZONE_IA
FILEBIN_FOLDER=dump

main() {
	OPT_NOTIFY=
	OPT_DELETE=
	ARGS=()

	while getopts ":nd" opt; do
		case $opt in
			n)
				OPT_NOTIFY=1
				ARGS+=(-n)
				;;
			d)
				OPT_DELETE=1
				ARGS+=(-d)
				;;
			:)
				echo "Expected argument for option: -$OPTARG" >&2
				usage >&2
				return 1
				;;
			\?)
				echo "Invalid option: -$OPTARG" >&2
				usage >&2
				return 1
				;;
		esac
	done

	for CONF_FILE in /etc/arc/filebin.conf ${XDG_CONFIG_HOME-$HOME/.config}/filebin/config ${FILEBIN_CONFIG_FILE-}; do
		if [[ -f $CONF_FILE ]]; then
			source "$CONF_FILE"
		fi
	done

	export AWS_DEFAULT_PROFILE AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY

	FILE="$1"

	if [[ -d "$FILE" ]]; then
		for f in $FILE/*; do
			url=$("$0" "$f" ${ARGS[@]+"${ARGS[@]}"})
			echo "$url"
		done
	else
		NEWFILENAME="$(filebin_key "$FILE")"

		URL="https://${FILEBIN_S3_BUCKET}.s3.amazonaws.com/${NEWFILENAME}"

		echo "$URL"

		aws s3 cp \
			--storage-class "$FILEBIN_S3_CLASS" \
			"$FILE" "s3://${FILEBIN_S3_BUCKET}/${NEWFILENAME}"

		if [[ -n $OPT_DELETE ]]; then
			rm -f "$FILE"
		fi

		if [[ -n $OPT_NOTIFY ]]; then
			filebin_notify
		fi
	fi
}

# functions can be overridden

filebin_key() {
	FILENAME=$(basename "$1")
	HASH=$(sha1sum "$1")
	HASH=${HASH:2:8}

	echo "${FILEBIN_FOLDER}/${HASH}/${FILENAME}"
}

filebin_notify() {
	curl -fsSL http://new.boxcar.io/api/notifications \
		-d "user_credentials=$FILEBIN_BOXCAR_KEY" \
		-d "notification[title]=filebin: $(basename "$FILE")" \
		-d "notification[long_message]=$URL" \
		-d "notification[sound]=no-sound" > /dev/null &
}

main "$@"
