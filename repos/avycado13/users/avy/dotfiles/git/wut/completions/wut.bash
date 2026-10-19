# bash completion for wut

_wut_completion() {
	local cur prev
	COMPREPLY=()
	cur="${COMP_WORDS[COMP_CWORD]}"
	prev="${COMP_WORDS[COMP_CWORD - 1]}"

	local commands="init new list go path rm"
	local global_opts="--help -h --version -V"

	# Complete global flags anywhere
	if [[ ${cur} == -* ]]; then
		case ${COMP_WORDS[1]} in
		new)
			mapfile -t COMPREPLY < <(compgen -W "--from" -- "${cur}")
			;;
		rm)
			mapfile -t COMPREPLY < <(compgen -W "--force" -- "${cur}")
			;;
		*)
			mapfile -t COMPREPLY < <(compgen -W "${global_opts}" -- "${cur}")
			;;
		esac
		return 0
	fi

	# First argument: command
	if [[ ${COMP_CWORD} -eq 1 ]]; then
		mapfile -t COMPREPLY < <(compgen -W "${commands} ${global_opts}" -- "${cur}")
		return 0
	fi

	# Get branches for completions
	local branches=""
	if git rev-parse --git-dir &>/dev/null 2>&1; then
		branches=$(git worktree list --porcelain 2>/dev/null | awk '/^branch / { b = substr($0, 8); gsub(/^refs\/heads\//, "", b); print b }')
	fi

	# Command-specific completions
	case ${COMP_WORDS[1]} in
	go | path)
		mapfile -t COMPREPLY < <(compgen -W "${branches}" -- "${cur}")
		;;
	rm)
		if [[ ${prev} != "--force" ]]; then
			mapfile -t COMPREPLY < <(compgen -W "${branches} --force" -- "${cur}")
		else
			mapfile -t COMPREPLY < <(compgen -W "${branches}" -- "${cur}")
		fi
		;;
	new)
		if [[ ${prev} == "--from" ]]; then
			# Complete git refs
			local refs
			refs=$(git for-each-ref --format='%(refname:short)' 2>/dev/null)
			mapfile -t COMPREPLY < <(compgen -W "${refs}" -- "${cur}")
		fi
		;;
	esac

	return 0
}

complete -F _wut_completion wut
