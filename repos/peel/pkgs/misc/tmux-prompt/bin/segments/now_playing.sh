# Print current playing song in your music player of choice.
source "${TMUX_POWERLINE_DIR_LIB}/text_roll.sh"

TMUX_POWERLINE_SEG_NOW_PLAYING_MUSIC_PLAYER="itunes"
TMUX_POWERLINE_SEG_NOW_PLAYING_MAX_LEN="25"
TMUX_POWERLINE_SEG_NOW_PLAYING_TRIM_METHOD="trim"
TMUX_POWERLINE_SEG_NOW_PLAYING_ROLL_SPEED="5"
TMUX_POWERLINE_SEG_NOW_PLAYING_NOTE_CHAR="♫"

run_segment() {
	if [ -z "$TMUX_POWERLINE_SEG_NOW_PLAYING_MUSIC_PLAYER" ]; then
		return 1
	fi

	local np
	case "$TMUX_POWERLINE_SEG_NOW_PLAYING_MUSIC_PLAYER" in
		"itunes")  np=$(__np_itunes) ;;
		"spotify")  np=$(__np_spotify) ;;
		*)
			echo "Unknown music player type [${TMUX_POWERLINE_SEG_NOW_PLAYING_MUSIC_PLAYER}]";
			return 1
	esac
	local exitcode="$?"
	if [ "${exitcode}" -ne 0 ]; then
		return ${exitcode}
	fi
	if [ -n "$np" ]; then
		case "$TMUX_POWERLINE_SEG_NOW_PLAYING_TRIM_METHOD" in
			"roll")
				np=$(roll_text "${np}" ${TMUX_POWERLINE_SEG_NOW_PLAYING_MAX_LEN} ${TMUX_POWERLINE_SEG_NOW_PLAYING_ROLL_SPEED})
				;;
			"trim")
				np=${np:0:TMUX_POWERLINE_SEG_NOW_PLAYING_MAX_LEN}
				;;
		esac
		echo "${np}"
	fi
	return 0
}

__np_itunes() {
	[ ! shell_is_osx ] && return 1
	np=$(${TMUX_POWERLINE_DIR_SEGMENTS}/np_itunes.script)
	echo "$np"
}

__np_spotify() {
	if shell_is_linux; then
		metadata=$(dbus-send --reply-timeout=42 --print-reply --dest=org.mpris.MediaPlayer2.spotify / org.freedesktop.MediaPlayer2.GetMetadata 2>/dev/null)
		if [ "$?" -eq 0 ] && [ -n "$metadata" ]; then
			# TODO how do one express this with dbus-send? It works with qdbus but the problem is that it's probably not as common as dbus-send.
			state=$(qdbus org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get org.mpris.MediaPlayer2.Player PlaybackStatus)
			if [[ $state == "Playing" ]]; then
				artist=$(echo "$metadata" | grep -PA2 "string\s\"xesam:artist\"" | tail -1 | grep -Po "(?<=\").*(?=\")")
				track=$(echo "$metadata" | grep -PA1 "string\s\"xesam:title\"" | tail -1 | grep -Po "(?<=\").*(?=\")")
				np=$(echo "${artist} - ${track}")
			fi
		fi
	elif shell_is_osx; then
		np=$(${TMUX_POWERLINE_DIR_SEGMENTS}/np_spotify_mac.script)
	fi
	echo "$np"
}
