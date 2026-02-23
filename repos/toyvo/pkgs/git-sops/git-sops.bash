#!/usr/bin/env bash
# taken from https://github.com/getsops/sops/issues/1137#issuecomment-2498480677

PS4='${LINENO}: '

set -euo pipefail

# Exit if the operation and file names were not given
test $# -eq 2

# Exit if no stdin available.
# stdin is used to fed sops with the content to encrypt / decrypt.
test -t 0 && exit 1

# First arg passed to script.
# clean is meant to call sops encrypt
# smudge is meant to call sops decrypt
OP="${1}"

# Second arg passed to script.
# The file name is fed to sops --filename-override so that sops can apply the creation_rules
# based on .sops.yaml file in the root of the repo.
FILE_NAME="${2}"

decrypt() {
  #printf "begin decrypt\n" 1>&2
  sops --decrypt --filename-override "${FILE_NAME}" /dev/stdin
  #printf "end decrypt\n" 1>&2
}

encrypt() {
  sops --encrypt --filename-override "${FILE_NAME}" /dev/stdin
}

show() {
  printf "%s\n" "${@}"
}

# Gets the unencrypted content of stdin, without stripping the last newline.
INPUT=$(cat; echo x)
INPUT=${INPUT%x}

#printf "INPUT contains\n'%s'\n\n" "${INPUT}" 1>&2

# If OP is equal to smudge, just decrypt the stdin contents.
if [[ "${OP}" == "smudge" ]]
then
  #printf "OP is smudge / decrypt\n\n" 1>&2
  TMP=$(mktemp)
  : ${DECRYPTED=$(decrypt <<< "${INPUT}" 2> "$TMP" )}
  err=$(cat "$TMP")
  rm "$TMP"
  wrong_key_error_message="age: no identity matched any of the recipients"
  if [[ $err == *"${wrong_key_error_message}"* ]]; then
    #printf "%s" "${err}" 1>&2
    :
  else
    show "${DECRYPTED}"
  fi

  exit 0
fi

# If the OP is not "clean", exit
if [[ "${OP}" != "clean" ]]
then
  exit 1
fi

# The OP is "clean".
# Either the file was not committed yet, or the existing decrypted content is different
# from the input, in which case we output the new encrypted input.
# If the file was commited and its decrypted content is the same as the new input,
# output the old encrypted content.

#printf "OP is clean / encrypt\n\n" 1>&2

: ${NEW_ENCRYPTED_INPUT:=$(encrypt <<< "${INPUT}" 2>/dev/null )}

: ${ENCRYPTED_HEAD_CONTENTS:=$(git cat-file -p "HEAD:${FILE_NAME}" 2>/dev/null)}

# Bash command expansion trims trailing newlines. We add an "x" to the end of the string
# and then filter it out to preserve the last newline.
# This is not applied to all the cases, because sops is inconsistent in that it always ensures
# a newline, if one was not present before.
: ${DECRYPTED_HEAD_CONTENTS=$(decrypt <<< "${ENCRYPTED_HEAD_CONTENTS}" 2>/dev/null; echo x )}
DECRYPTED_HEAD_CONTENTS=${DECRYPTED_HEAD_CONTENTS%x}

#printf "current  ENCRYPTED_HEAD_CONTENTS contains\n'%s'\n\n" "${ENCRYPTED_HEAD_CONTENTS}" 1>&2
#printf "current  DECRYPTED_HEAD_CONTENTS contains\n'%s'\n\n" "${DECRYPTED_HEAD_CONTENTS}" 1>&2
#printf "previous NEW_ENCRYPTED_INPUT contains\n'%s'\n\n" "${NEW_ENCRYPTED_INPUT}" 1>&2

if [[ -z "${ENCRYPTED_HEAD_CONTENTS}" || "${DECRYPTED_HEAD_CONTENTS}" != "${INPUT}" ]]
then
  show "${NEW_ENCRYPTED_INPUT}"
else
  show "${ENCRYPTED_HEAD_CONTENTS}"
fi
