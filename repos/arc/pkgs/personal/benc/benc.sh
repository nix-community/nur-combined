#!/bin/sh
set -eu
set -o pipefail

usage() {
	echo "Usage: $0 [OPTIONS...] DIR [OUTPUT_DIR]"
	echo " [-h]: show this help"
	echo " [-d]: delete source files"
	echo " [-c COMPRESSION]: compression command: lz4, gzip, bzip2, xz [default: lz4]"
	echo " [-C COMPRESSION_OPTIONS]: compression commandline options"
	echo " [-K GPG_KEY]: GPG key to encrypt for"
	echo
	echo " DIR: root directory to encrypt"
	echo " OUTPUT_DIR: directory to store output [default: DIR/encrypted]"
	echo
	echo "Encrypts a directory for storage"
}

main() {
	NAME="$(date -u +%y%m%d-%H%M%S)"
	OPT_GPG_KEY=
	OPT_COMP=lz4
	OPT_COMP_ARGS=
	OPT_DELETE=

	while getopts ":hdK:c:C:" opt; do
		case $opt in
			h) # --help
				usage
				return 0
				;;
			K) # --gpg-key KEY
				OPT_GPG_KEY="$OPTARG"
				;;
			d) # --delete-src
				OPT_DELETE=y
				;;
			c) # --compression COMP
				OPT_COMP="$OPTARG"
				;;
			C) # --compression-opts COMP
				OPT_COMP_ARGS="$OPTARG"
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
	shift $((OPTIND-1))

	if [ $# -lt 1 ]; then
		usage >&2
		return 1
	fi

	DIR="$1"
	OUTPUT="${2-$DIR/encrypted}"

	if ! [ -d "$DIR" ]; then
		echo "directory '$DIR' does not exist" >&2
		return 1
	fi

	case "$OPT_COMP" in
		lz4)
			COMP_EXT=".lz4"
			COMP_CMD="lz4 -cz"
			;;
		gzip)
			COMP_EXT=".gz"
			COMP_CMD="gzip -c"
			;;
		bzip2)
			COMP_EXT=".bz2"
			COMP_CMD="bzip2 -cz"
			;;
		xz)
			COMP_EXT=".xz"
			COMP_CMD="xz -czT0"
			;;
		*)
			echo "unknown compression" >&2
			usage >&2
			return 1
			;;
	esac
	COMP_CMD="$COMP_CMD $OPT_COMP_ARGS"

	GPG_EXT=
	if [ -n "$OPT_GPG_KEY" ]; then
		GPG_EXT=".gpg"
	fi

	for f in $(find "$DIR" -mindepth 1 -maxdepth 1 ! -name '.*'); do
		FNAME="$(basename "$f")"

		if [ -L "$f" ]; then
			f="$(readlink -e "$f")"
		fi

		if [ -d "$f" ]; then
			OUTNAME="$OUTPUT/$FNAME.tar"
		else
			OUTNAME="$OUTPUT/$FNAME"
		fi
		OUTNAME="$OUTNAME$COMP_EXT$GPG_EXT"

		SRC_STAMP=$(stampof "$f")
		if [ -f "$OUTNAME" ]; then
			DST_STAMP=$(stampof "$OUTNAME")

			if [ $SRC_STAMP -le $DST_STAMP ]; then
				continue
			fi
		fi

		echo "encrypting $FNAME -> $OUTNAME" >&2

		if tarcat "$f" |
			$COMP_CMD |
			gpgcat "$OPT_GPG_KEY" \
			> "$OUTNAME"; then
			touch -d "@$SRC_STAMP" "$OUTNAME"
			if [ -n "$OPT_DELETE" ]; then
				rm -r "$f"
			fi
		else
			RETVAL=$?
			rm -f "$OUTNAME"
			return $RETVAL
		fi
	done
}

tarcat() {
	if [ -d "$1" ]; then
		tar --one-file-system --numeric-owner \
			--transform "s|^\\.|$(dirname "$1")|" \
			-c -C "$1" .
	else
		cat "$1"
	fi
}

gpgcat() {
	if [ -n "$1" ]; then
		gpg --compress-algo none --trust-model always -r "$1" --encrypt
	else
		cat
	fi
}

stampof() {
	if [ -d "$1" ]; then
		find "$1" -type f -print0 | xargs -0 stat -c%Y | sort -n | tail -n1 | grep '^.*$'
	elif [ -f "$1" ]; then
		stat -c%Y "$1"
	else
		echo 0
	fi
}

main "$@"
