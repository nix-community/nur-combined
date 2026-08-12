# shellcheck shell=bash
substituteStream() {
	local var=$1
	local description=$2
	shift 2

	while (("$#")); do
		local replace_mode="$1"
		case "$1" in
		--replace)
			# deprecated 2023-11-22
			# this will either get removed, or switch to the behaviour of --replace-fail in the future
			if ! "$_substituteStream_has_warned_replace_deprecation"; then
				echo "substituteStream() in derivation $name: WARNING: '--replace' is deprecated, use --replace-{fail,warn,quiet}. ($description)" >&2
				_substituteStream_has_warned_replace_deprecation=true
			fi
			replace_mode='--replace-warn'
			;&
		--replace-quiet | --replace-warn | --replace-fail)
			pattern="$2"
			replacement="$3"
			shift 3
			local savedvar
			savedvar="${!var}"
			eval "$var"'=${'"$var"'//"$pattern"/"$replacement"}'
			if [ "$pattern" != "$replacement" ]; then
				if [ "${!var}" == "$savedvar" ]; then
					if [ "$replace_mode" == --replace-warn ]; then
						printf "substituteStream() in derivation $name: WARNING: pattern %q doesn't match anything in %s\n" "$pattern" "$description" >&2
					elif [ "$replace_mode" == --replace-fail ]; then
						printf "substituteStream() in derivation $name: ERROR: pattern %q doesn't match anything in %s\n" "$pattern" "$description" >&2
						return 1
					fi
				fi
			fi
			;;

		--subst-var)
			local varName="$2"
			shift 2
			# check if the used nix attribute name is a valid bash name
			if ! [[ "$varName" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
				echo "substituteStream() in derivation $name: ERROR: substitution variables must be valid Bash names, \"$varName\" isn't." >&2
				return 1
			fi
			if [ -z ${!varName+x} ]; then
				echo "substituteStream() in derivation $name: ERROR: variable \$$varName is unset" >&2
				return 1
			fi
			pattern="@$varName@"
			replacement="${!varName}"
			eval "$var"'=${'"$var"'//"$pattern"/"$replacement"}'
			;;

		--subst-var-by)
			pattern="@$2@"
			replacement="$3"
			eval "$var"'=${'"$var"'//"$pattern"/"$replacement"}'
			shift 3
			;;

		*)
			echo "substituteStream() in derivation $name: ERROR: Invalid command line argument: $1" >&2
			return 1
			;;
		esac
	done

	printf "%s" "${!var}"
}

# put the content of a file in a variable
# fail loudly if provided with a binary (containing null bytes)
consumeEntire() {
	# read returns non-0 on EOF, so we want read to fail
	if IFS='' read -r -d '' "$1"; then
		echo "consumeEntire(): ERROR: Input null bytes, won't process" >&2
		return 1
	fi
}

substitute() {
	local input="$1"
	local output="$2"
	shift 2

	if [ ! -f "$input" ]; then
		echo "substitute(): ERROR: file '$input' does not exist" >&2
		return 1
	fi

	local content
	consumeEntire content <"$input"

	if [ -e "$output" ]; then chmod +w "$output"; fi
	substituteStream content "file '$input'" "$@" >"$output"
}

substituteInPlace() {
	local -a fileNames=()
	for arg in "$@"; do
		if [[ "$arg" = "--"* ]]; then
			break
		fi
		fileNames+=("$arg")
		shift
	done
	if ! [[ "${#fileNames[@]}" -gt 0 ]]; then
		echo >&2 "substituteInPlace called without any files to operate on (files must come before options!)"
		return 1
	fi

	for file in "${fileNames[@]}"; do
		substitute "$file" "$file" "$@"
	done
}
