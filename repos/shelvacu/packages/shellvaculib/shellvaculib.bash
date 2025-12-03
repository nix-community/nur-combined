: # adding a nothing line at top so that shellcheck disable doesn't accidentally apply to the whole file.

# the entire point is to be sh-compatible
# shellcheck disable=SC2292
if [ -z "${BASH_VERSINFO-}" ]; then
  echo "shellvaculib.bash: This script only works with bash" >&2
  exit 1
fi

# Test if this file was sourced, see https://stackoverflow.com/a/28776166
if ! (return 0 2>/dev/null); then
  # this file was *not* sourced
  echo "shellvaculib.bash: This file should not be run directly, it should only be sourced" >&2
  exit 1
fi

if [[ ${SHELLVACULIB_COMPAT-0} == 1 ]]; then
  : # nothing
else
  set -euo pipefail
  shopt -s shift_verbose
  shopt -s lastpipe
fi

svl_eprintln() {
  printf '%s' "$@" >&2
  printf '\n' >&2
}

_shellvaculib_debug_enabled() {
  [[ ${SHELLVACULIB_DEBUG-0} == 1 ]]
}

_shellvaculib_debug_print() {
  # shellcheck disable=SC2310
  if _shellvaculib_debug_enabled; then
    svl_eprintln "$@"
  fi
}

# shellcheck disable=SC2310
if _shellvaculib_debug_enabled; then
  svl_eprintln "shellvaculib.bash sourced."
  declare dollar_zero dollar_underscore
  dollar_zero="$0"
  dollar_underscore="$_"
  declare -a dollar_at
  dollar_at=("$@")
  declare -p dollar_zero dollar_underscore dollar_at
  cmd=(
    declare -p
    HOME
    CDPATH
    PATH
    IFS

    COLUMNS
    LINES

    PWD
    OLDPWD
    DIRSTACK

    UID
    EUID
    GROUPS

    BASH
    BASHOPTS
    BASHPID
    PPID
    BASH_ARGC
    BASH_ARGV
    BASH_ARGV0
    BASH_COMMAND
    BASH_COMPAT
    BASH_EXECUTION_STRING
    BASH_LINENO
    BASH_SOURCE
    BASH_SUBSHELL
    BASH_VERSINFO
    BASH_VERSION
    BASH_XTRACEFD
    CHILD_MAX
    COPROC
    EPOCHREALTIME
    EXECIGNORE
    FIGNORE
    FUNCNAME
    FUNCNEST
    GLOBIGNORE
    histchars
    HISTCMD
    HISTCONTROL
    HISTFILE
    HISTFILESIZE
    HISTIGNORE
    HISTSIZE
    HISTTIMEFORMAT
    HOSTFILE
    HOSTNAME
    HOSTTYPE
    INPUTRC
    LANG
    LC_ALL
    LC_COLLATE
    LC_CTYPE
    LC_MESSAGES
    LC_NUMERIC
    LC_TIME
    LINENO
    MACHTYPE
    MAILCHECK
    OPTERR
    PIPESTATUS
    POSIXLY_CORRECT
    PROMPT_COMMAND
    PROMPT_DIRTRIM
    PS0
    PS1
    PS2
    PS3
    PS4
    SECONDS
    SHELL
    SHELLOPTS
    SHLVL
    TIMEFORMAT
    TMPDIR
  )
  "${cmd[@]}" || true
fi

declare -ga _shellvaculib_script_args
declare -g _shellvaculib_arg0 _shellvaculib_arg0_canonicalized _shellvaculib_initialized

if [[ ${_shellvaculib_initialized-} != 1 ]]; then
  _shellvaculib_arg0="$0"
  _shellvaculib_script_args=("$@")
  if ! _shellvaculib_arg0_canonicalized="$(realpath -- "$0")"; then
    svl_eprintln "warn: could not get realpath of \$0: $0"
    _shellvaculib_arg0_canonicalized=""
  fi
  _shellvaculib_initialized=true
else
  svl_eprintln "warn: shellvaculib re-sourced"
fi

# svl_err [message parts..]
# ex: svl_err
#   assuming $0 is ./myscript.sh
#   prints "./myscript.sh: unspecified error"
# ex: svl_err "you froblicated incorrectly!"
#   prints "./myscript.sh: you froblicated incorrectly!"
svl_err() {
  declare prefix

  if [[ -n ${SVL_PREFIX_NAME:-} ]]; then
    prefix="${SVL_PREFIX_NAME}"
  elif [[ -z ${0-} ]] ; then
    prefix="**unknown**"
  elif [[ ${SHELL-} != "" ]] && [[ $0 == "${SHELL-}" ]]; then
    prefix="\$SHELL"
  else
    prefix="$0"
  fi
  if [[ $# == 0 ]]; then
    printf '%s: unspecified error\n' "$prefix" >&2
  else
    printf '%s: %s\n' "$prefix" "$*" >&2
  fi
}

# svl_die [message parts..]
# same as svl_err except exits with code 1
svl_die() {
  svl_err "$@"
  exit 1
}

# svl_throw_skip {skip_count:int} [message parts..]
# if this is an error in the current function, just call svl_throw (equivalent to skip_count 0)
# if this is an error in the caller of this function, skip_count should be 1
# caller's caller: 2, etc.
svl_throw_skip() {
  if [[ $# == 0 ]]; then
    svl_die "svl_throw_skip expects at least one arg"
  fi
  declare -i skip="$1" i
  shift
  #always skip svl_throw_skip itself
  skip=$((skip + 1))
  for ((i = ${#FUNCNAME[@]} - 1; i >= skip; i--)); do
    svl_err "in ${FUNCNAME[i]} from ${BASH_SOURCE[i - 1]} line ${BASH_LINENO[i - 1]}"
  done
  svl_die "$@"
}

# svl_throw [message parts..]
svl_throw() {
  svl_throw_skip 1 "$@"
}

declare -gi _shellvaculib_max_args=1000000

_shellvaculib_min_andor_max_args_impl() {
  declare -i actual_count="$1" minimum_count="$2" maximum_count="$3"
  if ((minimum_count <= actual_count)) && ((actual_count <= maximum_count)); then
    return 0
  fi
  if ((actual_count < 0)) || ((minimum_count < 0)) || ((maximum_count < 0)); then
    svl_die "this shouldn't happen (one of the counts negative in ${FUNCNAME[0]})"
  fi
  declare expect_message
  if ((minimum_count == 0)) && ((maximum_count == 0)); then
    expect_message="expected no arguments"
  elif ((minimum_count == maximum_count)) && ((maximum_count == 1)); then
    expect_message="expected exactly 1 argument"
  elif ((minimum_count == maximum_count)); then
    expect_message="expected exactly $minimum_count argument(s)"
  elif ((minimum_count == 0)) && ((maximum_count != _shellvaculib_max_args)); then
    expect_message="expected at most $maximum_count argument(s)"
  elif ((minimum_count != 0)) && ((maximum_count == _shellvaculib_max_args)); then
    expect_message="expected at least $minimum_count argument(s)"
  elif ((minimum_count != 0)) && ((maximum_count != _shellvaculib_max_args)); then
    expect_message="expected between $minimum_count and $maximum_count arguments"
  else
    svl_die "this shouldnt be possible really"
  fi
  declare error_message="Wrong number of arguments: $expect_message, got $actual_count"

  declare -i skip_depth=2
  # if svl_*_args was called from the top-level (validating a script's arguments), then FUNCNAME will be
  # ("_shellvaculib_min_andor_max_args_impl" "svl_*_args" "main")
  if (( ${#FUNCNAME[@]} == (skip_depth + 1) )); then
    #we are being called from the top-level
    svl_die "$error_message"
  else
    svl_throw_skip $skip_depth "$error_message"
  fi
}

# svl_minmax_args $# {min:int} {max:int}
svl_minmax_args() {
  if [[ $# != 3 ]]; then
    svl_throw_skip 1 "expected 3 args to svl_minmax_args, got $#"
  fi
  _shellvaculib_min_andor_max_args_impl "$1" "$2" "$3"
}

# svl_min_args $# {min:int}
svl_min_args() {
  if [[ $# != 2 ]]; then
    svl_throw_skip 1 "expected 2 args to svl_min_args, got $#"
  fi
  _shellvaculib_min_andor_max_args_impl "$1" "$2" "$_shellvaculib_max_args"
}

# svl_max_args $# {max:int}
svl_max_args() {
  if [[ $# != 2 ]]; then
    svl_throw_skip 1 "expected 2 args to svl_max_args, got $#"
  fi
  _shellvaculib_min_andor_max_args_impl "$1" 0 "$2"
}

# svl_exact_args $# {exact_arg_count:int}
svl_exact_args() {
  if [[ $# != 2 ]]; then
    svl_throw_skip 1 "expected 2 args to svl_exact_args, got $#"
  fi
  _shellvaculib_min_andor_max_args_impl "$1" "$2" "$2"
}

# svl_no_args $#
svl_no_args() {
  if [[ $# != 1 ]]; then
    svl_throw_skip 1 "expected 1 arg to svl_no_args, got $#"
  fi
  _shellvaculib_min_andor_max_args_impl "$1" 0 0
}

# svl_idempotent_add_prompt_command {cmd}
svl_idempotent_add_prompt_command() {
  svl_exact_args $# 1
  PROMPT_COMMAND[0]=''${PROMPT_COMMAND[0]:-}
  declare to_add="$1" cmd
  for cmd in "${PROMPT_COMMAND[@]}"; do
    if [[ $to_add == "$cmd" ]]; then
      return 0
    fi
  done
  PROMPT_COMMAND+=("$to_add")
  return 0
}

# svl_probably_in_script_dir
#   (no args)
# because the folder containing the script as well as PWD can be deleted while we're using it (or its parents), it's impossible to know for sure. Woohoo!
# shellcheck disable=SC2120
svl_probably_in_script_dir() {
  svl_no_args $#
  declare script_dir canon_pwd
  if [[ -z $_shellvaculib_arg0_canonicalized ]]; then
    _shellvaculib_debug_print "svl_probably_in_script_dir called when _shellvaculib_arg0_canonicalized is unset or blank, returning false (1)"
    return 1
  fi
  if ! script_dir="$(dirname -- "$_shellvaculib_arg0_canonicalized")"; then
    # shellcheck disable=SC2016  # this is intentionally not expanding
    _shellvaculib_debug_print 'svl_probably_in_script_dir failed to call $(dirname -- $_shellvaculib_arg0_canonicalized), returning false (1)'
    return 1
  fi
  if ! canon_pwd="$(realpath -- "$PWD")"; then
    # shellcheck disable=SC2016  # this is intentionally not expanding
    _shellvaculib_debug_print 'svl_probably_in_script_dir failed to call $(realpath -- $PWD), returning false (1)'
    return 1
  fi
  [[ $script_dir == "$canon_pwd" ]]
}

# svl_assert_probably_in_script_dir
#   (no args)
# shellcheck disable=SC2120
svl_assert_probably_in_script_dir() {
  svl_no_args $#
  # shellcheck disable=SC2310
  if ! svl_probably_in_script_dir; then
    svl_die "This script must be run in its directory"
  fi
  return 0
}

# svl_assert_root
#   (no args)
# shellcheck disable=SC2120
svl_assert_root() {
  svl_no_args $#
  if [[ -z ${EUID:-} ]]; then
    svl_throw 'EUID unset!?'
  fi
  if [[ $EUID != 0 ]]; then
    svl_die "must be root to run this"
  fi
  return 0
}

# svl_auto_sudo
#   (no args)
# shellcheck disable=SC2120
svl_auto_sudo() {
  if [[ -z ${EUID:-} ]]; then
    svl_throw 'EUID unset!?'
  fi
  if [[ $EUID == 0 ]]; then
    return 0
  fi
  if [[ ${SHELLVACULIB_IN_AUTO_SUDO:-} == 1 ]]; then
    svl_throw 'svl_auto_sudo: already inside auto-sudo and failed :('
  fi
  declare sudo_path
  sudo_path="$(command -v sudo)"
  exec "$sudo_path" SHELLVACULIB_IN_AUTO_SUDO=1 -- "$_shellvaculib_arg0" "${_shellvaculib_script_args[@]}"
}

# svl_in_array {needle} [haystack..]
# false (return code 1) when haystack is empty
svl_in_array() {
  svl_min_args $# 1
  declare needle="$1" value
  shift 1

  for value; do
    if [[ $value == "$needle" ]]; then
      return 0
    fi
  done
  return 1
}

# svl_ask [-opts..] [--] [question]
# ex: svl_ask
# ex: svl_ask "Are you sure you want to rotate the transcordial syncophactor?"
#   --result-var {name:name} required
#   --default-yes
#   --default-no
#   --long-yes
#   --short-yes
#
# Use like:
#
# declare question_response
# svl_ask --result-var question_response "Are you sure you want to do that?"
# if [[ $question_response == true ]]; then
#   # ...
# fi
svl_ask() {
  declare -A _shellvaculib_svl_ask__vars=(
    [default_yes]="false"
    [short_yes]="null"
    [result_var_name]=""
    [arg]=""
  )
  declare -a _shellvaculib_svl_ask__non_option_args=()
  while (($# > 0)); do
    _shellvaculib_svl_ask__vars[arg]="$1"
    shift
    case "${_shellvaculib_svl_ask__vars[arg]}" in
    -y | --default-yes)
      _shellvaculib_svl_ask__vars[default_yes]="true"
      ;;
    --default-no)
      _shellvaculib_svl_ask__vars[default_yes]="false"
      ;;
    --short-yes)
      _shellvaculib_svl_ask__vars[short_yes]="true"
      ;;
    --long-yes)
      _shellvaculib_svl_ask__vars[short_yes]="false"
      ;;
    --result-var)
      if (($# == 0)); then
        svl_throw_skip 1 "no arg passed to --result-var in svl_ask"
      fi
      _shellvaculib_svl_ask__vars[result_var_name]="$1"
      shift
      ;;
    --)
      _shellvaculib_svl_ask__non_option_args+=("$@")
      shift $#
      break
      ;;
    -*)
      svl_throw_skip 1 "invalid option \`${_shellvaculib_svl_ask__vars[arg]}' for svl_ask"
      ;;
    *)
      _shellvaculib_svl_ask__non_option_args+=("${_shellvaculib_svl_ask__vars[arg]}")
      ;;
    esac
  done

  if [[ $# != 0 ]]; then
    svl_throw "bug in arg parsing, no args should be left but there are $# left"
  fi

  if [[ ${_shellvaculib_svl_ask__vars[result_var_name]-} == "" ]]; then
    svl_throw_skip 1 "must set --result-var in svl_ask"
  fi
  if [[ ${_shellvaculib_svl_ask__vars[result_var_name]} == _shellvaculib_svl_ask__* ]]; then
    svl_throw_skip 1 "bad var name"
  fi

  if [[ ${_shellvaculib_svl_ask__vars[short_yes]} == null ]]; then
    _shellvaculib_svl_ask__vars[short_yes]="${_shellvaculib_svl_ask__vars[default_yes]}"
  fi

  svl_max_args ${#_shellvaculib_svl_ask__non_option_args[@]} 1
  if [[ ${#_shellvaculib_svl_ask__non_option_args[@]} == 0 ]]; then
    _shellvaculib_svl_ask__vars[prompt]="Are you sure you want to continue?"
  else
    _shellvaculib_svl_ask__vars[prompt]="${_shellvaculib_svl_ask__non_option_args[0]}"
  fi
  if [[ ${_shellvaculib_svl_ask__vars[short_yes]} == true ]]; then
    _shellvaculib_svl_ask__vars[yes_prompt]="y"
  else
    _shellvaculib_svl_ask__vars[yes_prompt]="yes"
  fi
  _shellvaculib_svl_ask__vars[no_prompt]="n"
  if [[ ${_shellvaculib_svl_ask__vars[default_yes]} == true ]]; then
    svl_capitalize_var "_shellvaculib_svl_ask__vars[yes_prompt]"
  else
    svl_capitalize_var "_shellvaculib_svl_ask__vars[no_prompt]"
  fi
  _shellvaculib_svl_ask__vars[full_prompt]="${_shellvaculib_svl_ask__vars[prompt]} [${_shellvaculib_svl_ask__vars[yes_prompt]}/${_shellvaculib_svl_ask__vars[no_prompt]}]: "

  declare -a _shellvaculib_svl_ask__yes_responses=("yes")
  declare -a _shellvaculib_svl_ask__no_responses=("no" "n")
  if [[ ${_shellvaculib_svl_ask__vars[short_yes]} == true ]]; then
    _shellvaculib_svl_ask__yes_responses+=("y")
  fi
  if [[ ${_shellvaculib_svl_ask__vars[default_yes]} == true ]]; then
    _shellvaculib_svl_ask__yes_responses+=("")
  else
    _shellvaculib_svl_ask__no_responses+=("")
  fi

  while true; do
    read -r -p "${_shellvaculib_svl_ask__vars[full_prompt]}" "_shellvaculib_svl_ask__vars[response]" || true
    svl_trim_var "_shellvaculib_svl_ask__vars[response]"
    svl_downcase_var "_shellvaculib_svl_ask__vars[response]"
    if svl_in_array "${_shellvaculib_svl_ask__vars[response]}" "${_shellvaculib_svl_ask__yes_responses[@]}"; then
      _shellvaculib_svl_ask__vars[result]="true"
      break
    fi
    if svl_in_array "${_shellvaculib_svl_ask__vars[response]}" "${_shellvaculib_svl_ask__no_responses[@]}"; then
      _shellvaculib_svl_ask__vars[result]="false"
      break
    fi
    printf "Unrecognized response %q\n" "$response"
  done
  declare -n _shellvaculib_svl_ask__result_ref="${_shellvaculib_svl_ask__vars[result_var_name]}"
  _shellvaculib_svl_ask__result_ref="${_shellvaculib_svl_ask__vars[result]}"
}

# svl_confirm_or_die [args for svl_ask..]
# ex: svl_confirm_or_die
# ex: svl_confirm_or_die -- "Are you sure you want to rotate the transcordial syncophactor?"
#   accepts same args as svl_ask, except don't pass --result-var
# exits if answer is no
svl_confirm_or_die() {
  declare arg
  for arg; do
    case "$arg" in
    --result-var)
      svl_throw_skip 1 "--result-var not allowed in svl_confirm_or_die"
      ;;
    --)
      break
      ;;
    esac
  done
  declare question_result
  svl_ask --result-var question_result "$@"
  if [[ $question_result == true ]]; then
    return 0
  else
    svl_die "exiting"
  fi
}

# svl_count [args...]
# ex: svl_count #=> 0
# ex: svl_count a b c #=> 3
# prints the number of arguments and a newline on stdout.
svl_count() {
  echo $#
  return 0
}

# svl_args_into {array:name} [args..]
# appends args to array. Useful because bash has slightly different treatment of expansions inside 'a=(foo)' and 'cmd foo'
svl_args_into() {
  svl_min_args $# 1
  if [[ $1 == _shellvaculib_svl_args_into__* ]]; then
    svl_throw_skip 1 "bad var name"
  fi
  declare -n _shellvaculib_svl_args_into__var_ref="$1"
  shift 1
  _shellvaculib_svl_args_into__var_ref+=("$@")
}

# svl_expand_into {array_var_name} {pattern}
# ex:
#   declare -a matches
#   svl_expand_into matches 'foo*bar'
# the pattern is expanded with
#   dotglob set
#   extglob set
#   failglob unset
#   globasciiranges set
#   globskipdots set
#   globstar set
#   nocaseglob unset
#   nocasematch unset
#   nullglob set
svl_expand_into() {
  svl_exact_args $# 2
  if [[ $1 == _shellvaculib_svl_expand_into__* ]]; then
    svl_throw_skip 1 "bad var name"
  fi
  declare -A _shellvaculib_svl_expand_into__shopt_new_values=(
    [dotglob]=set
    [extglob]=set
    [failglob]=unset
    [globasciiranges]=set
    [globskipdots]=set
    [globstar]=set
    [nocaseglob]=unset
    [nocasematch]=unset
    [nullglob]=set
  )
  declare -a _shellvaculib_svl_expand_into__shopt_will_set=() _shellvaculib_svl_expand_into__shopt_will_unset=()
  declare _shellvaculib_svl_expand_into__shopt_name
  for _shellvaculib_svl_expand_into__shopt_name in "${!_shellvaculib_svl_expand_into__shopt_new_values[@]}"; do
    declare _shellvaculib_svl_expand_into__old_value
    if shopt -q "$_shellvaculib_svl_expand_into__shopt_name"; then
      _shellvaculib_svl_expand_into__old_value="set"
    else
      _shellvaculib_svl_expand_into__old_value="unset"
    fi
    declare _shellvaculib_svl_expand_into__new_value="${_shellvaculib_svl_expand_into__shopt_new_values["$_shellvaculib_svl_expand_into__shopt_name"]}"
    if [[ $_shellvaculib_svl_expand_into__old_value == "$_shellvaculib_svl_expand_into__new_value" ]]; then
      continue
    elif [[ $_shellvaculib_svl_expand_into__new_value == set ]]; then
      _shellvaculib_svl_expand_into__shopt_will_set+=("$_shellvaculib_svl_expand_into__shopt_name")
    elif [[ $_shellvaculib_svl_expand_into__new_value == unset ]]; then
      _shellvaculib_svl_expand_into__shopt_will_unset+=("$_shellvaculib_svl_expand_into__shopt_name")
    else
      svl_throw "this shouldn't be possible"
    fi
  done
  if [[ ${#_shellvaculib_svl_expand_into__shopt_will_set[@]} != 0 ]]; then
    shopt -s "${_shellvaculib_svl_expand_into__shopt_will_set[@]}"
  fi
  if [[ ${#_shellvaculib_svl_expand_into__shopt_will_unset[@]} != 0 ]]; then
    shopt -u "${_shellvaculib_svl_expand_into__shopt_will_unset[@]}"
  fi
  # intentional expansion of arg
  # shellcheck disable=SC2086
  svl_args_into "$1" $2
  # inverse of what we did above, to put things back as they were
  if [[ ${#_shellvaculib_svl_expand_into__shopt_will_set[@]} != 0 ]]; then
    shopt -u "${_shellvaculib_svl_expand_into__shopt_will_set[@]}"
  fi
  if [[ ${#_shellvaculib_svl_expand_into__shopt_will_unset[@]} != 0 ]]; then
    shopt -s "${_shellvaculib_svl_expand_into__shopt_will_unset[@]}"
  fi
}

# svl_count_matches {pattern}
# ex: svl_count_matches 'foo*bar'
# the pattern is expanded with
#   dotglob set
#   extglob set
#   failglob unset
#   globasciiranges set
#   globskipdots set
#   globstar set
#   nocaseglob unset
#   nocasematch unset
#   nullglob set
# counts the number of matches and print to stdout
svl_count_matches() {
  svl_exact_args $# 1
  declare -a results=()
  svl_expand_into results "$1"
  echo "${#results[@]}"
}

svl_trim_var() {
  svl_exact_args $# 1
  if [[ $1 == _shellvaculib_svl_trim_var__* ]]; then
    svl_throw_skip 1 "bad var name"
  fi
  declare -n _shellvaculib_svl_trim_var__var_ref="$1"
  # remove leading whitespace characters
  _shellvaculib_svl_trim_var__var_ref="${_shellvaculib_svl_trim_var__var_ref#"${_shellvaculib_svl_trim_var__var_ref%%[![:space:]]*}"}"
  # remove trailing whitespace characters
  _shellvaculib_svl_trim_var__var_ref="${_shellvaculib_svl_trim_var__var_ref%"${_shellvaculib_svl_trim_var__var_ref##*[![:space:]]}"}"
}

svl_downcase_var() {
  svl_exact_args $# 1
  if [[ $1 == _shellvaculib_svl_downcase_var__* ]]; then
    svl_throw_skip 1 "bad var name"
  fi
  declare -n _shellvaculib_svl_downcase_var__var_ref="$1"
  _shellvaculib_svl_downcase_var__var_ref="${_shellvaculib_svl_downcase_var__var_ref,,}"
}

svl_upcase_var() {
  if [[ $1 == _shellvaculib_svl_upcase_var__* ]]; then
    svl_throw_skip 1 "bad var name"
  fi
  svl_exact_args $# 1
  declare -n _shellvaculib_svl_upcase_var__var_ref="$1"
  _shellvaculib_svl_upcase_var__var_ref="${_shellvaculib_svl_upcase_var__var_ref^^}"
}

svl_capitalize_var() {
  if [[ $1 == _shellvaculib_svl_capitalize_var__* ]]; then
    svl_throw_skip 1 "bad var name"
  fi
  svl_exact_args $# 1
  declare -n _shellvaculib_svl_capitalize_var__var_ref="$1"
  _shellvaculib_svl_capitalize_var__var_ref="${_shellvaculib_svl_capitalize_var__var_ref^}"
}

# svl_trim "  foo \n"
#   prints to stdout: "foo"
svl_trim() {
  svl_exact_args $# 1
  declare var="$1"
  svl_trim_var var
  printf '%s' "$var"
}

# svl_capture_exit_code_into {var_name:name} {cmd} [args...]
svl_capture_exit_code_into() {
  svl_min_args $# 2
  if [[ $1 == _shellvaculib_svl_capture_exit_code_into__* ]]; then
    svl_throw_skip 1 "bad var name"
  fi
  declare -n _shellvaculib_svl_capture_exit_code_into__var_ref="$1"
  shift
  if "$@"; then
    _shellvaculib_svl_capture_exit_code_into__var_ref=$?
  else
    _shellvaculib_svl_capture_exit_code_into__var_ref=$?
  fi
  return 0
}

# svl_capture_output_into {var_name:name} {cmd} [args...]
# almost the same as
#
#     var_name="$(cmd args...)"
#
# except that the final newlines, if present, are preserved
svl_capture_output_into() {
  svl_min_args $# 2
  if [[ $1 == _shellvaculib_svl_capture_output_into__* ]]; then
    svl_throw_skip 1 "bad var name"
  fi
  declare _shellvaculib_svl_capture_output_into__output
  declare -i _shellvaculib_svl_capture_output_into__return_code
  if _shellvaculib_svl_capture_output_into__output="$(if "$@"; then r=$?; else r=$?; fi; printf "/"; exit $r)"; then
    _shellvaculib_svl_capture_output_into__return_code=$?
  else
    _shellvaculib_svl_capture_output_into__return_code=$?
  fi
  declare -n _shellvaculib_svl_capture_output_into__result_ref="$1"
  _shellvaculib_svl_capture_output_into__result_ref="${_shellvaculib_svl_capture_output_into__output%/}"
  return $_shellvaculib_svl_capture_output_into__return_code
}


# svl_verbose_run cmd [args...]
svl_verbose_run() {
  svl_min_args $# 1
  declare cmd_str
  printf -v cmd_str '%q ' "$@"
  cmd_str="${cmd_str% }"
  svl_err "info: running $cmd_str"
  "$@"
}
