#!/usr/bin/env bash

# dependencies:
# $bin
# $qaac_unwrapped
# $bubblewrap
# bwrap-common.sh

set -eu

if [ -v QAAC_BWRAP_TRACE ] && [ $QAAC_BWRAP_TRACE = 1 ]; then
  set -x
fi



# parse help arg
__help=0
if [ $# == 0 ]; then __help=1; else
for a in "$@"; do case "$a" in
  -h|--help) __help=1; break;;
esac; done
fi
if [ -v QAAC_SHOW_REAL_HELP ] && [ "$QAAC_SHOW_REAL_HELP" = 1 ]; then
  __help=0
fi
if [ $__help = 1 ]; then
  # show cached help text. this is terribly slow with wine
  cat $qaac_unwrapped/share/doc/qaac/$bin.txt
  exit 1
fi
unset __help



export WINEPREFIX="$HOME"/.cache/qaac/wine

bwrap_args=(
  --tmpfs /tmp
  --ro-bind /nix/store /nix/store
  # fix: Fontconfig error: Cannot load default config file: No such file
  --ro-bind /etc/fonts /etc/fonts
  --bind "$WINEPREFIX" "$WINEPREFIX"
)

# TODO better? manage commands in order to run before and after the program
# do we need the commands in order, or does this always work?
pre_mkdir=()
pre_rm=()
pre_symlink=()
post_mv=()
post_rm=()
post_rmdir=() # TODO "rmdir" or "rm -rf"?
post_kill=()



# set default values
__=() # positional args
_d=() # Output directory. Default is current working dir.
__matrix_file=() # Matrix file for remix.
__tmpdir=() # Specify temporary directory. Default is %TMP%
__log=() # Output message to file.
_o=() # Specify output filename
__lyrics=()
__artwork=()
__chapter=() # Set chapter from file.
__help=0
__formats=0
__check=0
__peak=0

# parse args
g(){ if [ -n "$s" ]; then v="${s[0]}"; s=("${s[@]:1}"); return; fi; echo "error: missing value for argument $a" >&2; exit 1; }
s=("$@")
A=()
while [ ${#s[@]} != 0 ]; do a="${s[0]}"; s=("${s[@]:1}"); case "$a" in
  -d) g; rewrite_dir_path; _d+=("$v"); A+=("$a" "$v"); continue;;
  --matrix-file) g; __matrix_file+=("$v"); A+=("$a" "$v"); continue;;
  --tmpdir) g; rewrite_dir_path; __tmpdir+=("$v"); A+=("$a" "$v"); continue;;
  --log) g; rewrite_file_path --force; __log+=("$v"); A+=("$a" "$v"); continue;;
  -o) g; rewrite_file_path --force; _o+=("$v"); A+=("$a" "$v"); continue;;
  --lyrics) g; __lyrics+=("$v"); A+=("$a" "$v"); continue;;
  --artwork) g; __artwork+=("$v"); A+=("$a" "$v"); continue;;
  --chapter) g; __chapter+=("$v"); A+=("$a" "$v"); continue;;
  -h|--help) __help=1; A+=("$a"); continue;;
  --formats) __formats=1; A+=("$a"); continue;;
  --check) __check=1; A+=("$a"); continue;;
  --peak) __peak=1; A+=("$a"); continue;;
  # skip unused args
  --he|--adts|--no-smart-padding|-A|--alac|-D|--decode|--caf|--play|--no-dither|-N|--normalize|--limiter|--no-delay|--no-matrix-normalize|--no-optimize|-s|--silent|--verbose|-i|--ignorelength|--threading|-n|--nice|--sort-args|-S|--stat|--fname-from-tag|--concat|-R|--raw|--copy-artwork) A+=("$a");;
  -a|--abr|-V|--tvbr|-v|--cvbr|-c|--cbr|-q|--quality|-r|--rate|--lowpass|-b|--bits-per-sample|--gain|--drc|--start|--end|--delay|--num-priming|--gapless-mode|--matrix-preset|--chanmap|--chanmask|--text-codepage|--fname-format|--cue-tracks|--raw-channels|--raw-rate|--raw-format|--native-resampler|--title|--artist|--band|--album|--grouping|--composer|--comment|--genre|--date|--track|--disk|--compilation|--artwork-size|--tag|--tag-from-file|--long-tag) g; A+=("$a" "$v");;
  -[^-]*)
    p=()
    for ((i=1;i<${#a};i++)); do case "${a:$i:1}" in
      [ADNsinSR]) p+=("-${a:$i:1}"); continue;;
      [aVvcqdrbo]) p+=("-${a:$i:1}" "${a:$((i+1))}"); break;;
      *) echo "error: failed to parse argument ${a@Q}" >&2; exit 1;;
    esac; done;
    s=("${p[@]}" "${s[@]}"); p=; continue;;
  --) for v in "${s[@]}"; do __+=("$v"); A+=("$v"); done; s=; break;;
  *) v="$a"; a='--'; __+=("$v"); A+=("$v");;
esac; done

if [ $# == 0 ]; then __help=1; fi

# require output file path for whitelisting, aka binding
# otherwise qaac writes to ${input_path%.*}.{m4a,alac,wav,caf} or stdin.{m4a,alac,wav,caf}
# we could derive the output file path from options  but that is more work
# default: ${input_path%.*}.m4a
# -A, --alac             ALAC encoding mode -> ${input_path%.*}.alac (?)
# -D, --decode           Decode to a WAV file. -> ${input_path%.*}.wav
# --caf                  Output to CAF file instead of M4A/WAV/AAC. -> ${input_path%.*}.caf
if [ $__help = 0 ] && [ $__formats = 0 ] && [ $__check = 0 ] && [ $__peak = 0 ] && [ ${#_o[@]} = 0 ]; then
  echo "error: no output file path" >&2
  echo >&2
  echo "examples:" >&2
  echo "  qaac -o out.m4a" >&2
  echo "  qaac -o out.caf" >&2
  echo "  qaac -o out.wav" >&2
  echo "  qaac -o out.alac" >&2
  echo "  qaac -o - # write to stdout" >&2
  exit 1
fi

# by default, qaac picks the last -o path. lets be more strict here
if [ $__help = 0 ] && [ ${#_o[@]} != 0 ] && [ ${#_o[@]} != 1 ]; then
  echo "error: multiple output file paths" >&2
  exit 1
fi

# TODO ...
if false; then
# -d <dirname>           Output directory. Default is current working dir.
set_default_output_dir -d "$PWD"
# --tmpdir <dirname>     Specify temporary directory. Default is %TMP%
set_default_output_dir --tmpdir "${TMP:-/tmp}"
fi

# debug: print parsed values
if false; then
  echo "#A: ${#A[@]}"
  echo -n 'A:'; for a in "${A[@]}"; do echo -n " ${a@Q}"; done; echo
  for i in "${!__[@]}"; do v="${__[$i]}"; echo "__ $i: ${v@Q}"; done
  for i in "${!_d[@]}"; do v="${_d[$i]}"; echo "_d $i: ${v@Q}"; done
  for i in "${!__matrix_file[@]}"; do v="${__matrix_file[$i]}"; echo "__matrix_file $i: ${v@Q}"; done
  for i in "${!__tmpdir[@]}"; do v="${__tmpdir[$i]}"; echo "__tmpdir $i: ${v@Q}"; done
  for i in "${!__log[@]}"; do v="${__log[$i]}"; echo "__log $i: ${v@Q}"; done
  for i in "${!_o[@]}"; do v="${_o[$i]}"; echo "_o $i: ${v@Q}"; done
  for i in "${!__lyrics[@]}"; do v="${__lyrics[$i]}"; echo "__lyrics $i: ${v@Q}"; done
  for i in "${!__artwork[@]}"; do v="${__artwork[$i]}"; echo "__artwork $i: ${v@Q}"; done
  for i in "${!__chapter[@]}"; do v="${__chapter[$i]}"; echo "__chapter $i: ${v@Q}"; done
fi

# add args to bwrap_args
# -- = positional args
whitelist_path_opts if --matrix-file --lyrics --artwork --chapter --
#whitelist_path_opts of -o --log # no. done by rewrite_file_path
whitelist_path_opts od -d --tmpdir



# debug
false &&
for n in pre_mkdir pre_rm pre_symlink post_mv post_rmdir; do
  eval 'for i in ${!'$n'[@]}; do echo "'$n' $i: ${'$n'[$i]}"; done'
done



# finally: run the program

trap post_bwrap EXIT

args=(
  $bubblewrap/bin/bwrap "${bwrap_args[@]}" $qaac_unwrapped/bin/$bin "${A[@]}"
)

pre_bwrap

#set -x

"${args[@]}"

rc=$?

#set +x

post_bwrap

exit $rc
