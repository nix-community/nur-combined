source @shellvaculib@

declare -a nonOptionArgs rubyArgs scriptArgs=("$@")
declare -i i=-1
declare currentArg

function nextArg() {
  i=$((i + 1))
  if ((i < "${#scriptArgs[@]}")); then
    currentArg="${scriptArgs[$i]}"
  else
    unset currentArg
  fi
}

function rubyOptionWithArg() {
  svl_min_args $# 1
  declare argSpec
  for argSpec; do
    if [[ ${#argSpec} == 0 ]]; then
      svl_throw "given empty arg"
    elif [[ ${#argSpec} == 1 ]]; then
      if [[ $currentArg == "-${argSpec}"* ]]; then
        rubyArgs+=("$currentArg")
        if [[ $currentArg == "-${argSpec}" ]]; then
          nextArg
          [[ ${currentArg+x} == x ]] || svl_die 'invalid arguments'
          rubyArgs+=("$currentArg")
        fi
        return 0
      fi
    else
      if [[ $currentArg == "--$argSpec" ]]; then
        rubyArgs+=("$currentArg")
        nextArg
        [[ ${currentArg+x} == x ]] || svl_die 'invalid arguments'
        rubyArgs+=("$currentArg")
        return 0
      fi
    fi
  done
  return 1
}

function rubyOptionNoArg() {
  svl_minmax_args $# 1 2
  declare shortForm="$1"
  declare longForm="${2-}"
  if [[ $currentArg == "-$shortForm" ]] || ([[ -n $longForm ]] && [[ $currentArg == "--$longForm" ]]); then
    rubyArgs+=("$currentArg")
    return 0
  fi
  return 1
}

function rubyPassthru() {
  svl_min_args $# 1
  if svl_in_array "$currentArg" "$@"; then
    rubyArgs+=("$currentArg")
    return 0
  fi
  return 1
}

while true; do
  nextArg
  [[ ${currentArg+x} == x ]] || break

  rubyPassthru -W0 -W1 -W2 -W -w --inspect --noinspect --multiline --nomultiline --singleline --nosingleline --extra-doc-dir --echo --noecho --echo-on-assignment --noecho-on-assignment --truncate-echo-on-assignment --colorize --nocolorize --autocomplete --noautocomplete --regexp-completor --type-completor --verbose --noverbose --inf-ruby-mode --simple-prompt --noprompt --tracer && continue
  rubyOptionWithArg E encoding && continue
  rubyOptionWithArg I && continue
  rubyOptionNoArg U && continue
  rubyOptionNoArg d && continue
  rubyOptionNoArg f && continue
  rubyOptionWithArg prompt prompt-mode && continue
  rubyOptionWithArg back-trace-limit && continue
  if [[ $currentArg == "--" ]]; then
    nextArg
    nonOptionArgs+=("${scriptArgs[@]:i}")
    break
  fi
  if [[ $currentArg == -* ]]; then
    svl_die "unrecognized argument \`$currentArg'"
  fi
  nonOptionArgs+=("$currentArg")
done

@irb@ -rtime -ractive_support -ractive_support/all "${rubyArgs[@]}" -- "${nonOptionArgs[@]}"
