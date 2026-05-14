#!/usr/bin/env bash
set -Eeuo pipefail

message='Update spell check word list'
path="$ADD_WORDS_WORDLIST_PATH"
words=( "$@" )

add_words() {
  printf '%s\n' "$@" | sort "$path" - | uniq | sponge "$path"
}

handle_git() {
  if [[ -n "$(git status --porcelain "$path")" ]]; then
    echo "Error: Existing uncommitted changes to $path" >&2
    exit 1
  fi

  if [[ -n "$(git diff --cached --name-only)" ]]; then
    echo "Error: Existing staged changes" >&2
    exit 1
  fi

  add_words "${words[@]}"

  git add "$path"
  if [[ "$(git log -1 --pretty='%s')" == "$message" ]] && ! git merge-base --is-ancestor 'HEAD' '@{u}'; then
    git commit --amend --no-edit
  else
    git commit --message "$message"
  fi
  git show 'HEAD'
}

handle_jj() {
  local current_change current_parent_change reused_change
  current_change="$(jj_find_change '@')"
  current_parent_change="$(jj_find_change '@-')"
  reused_change="$(jj_find_change "main+:: & description(exact:\"$message\n\")")"

  if [[ -n "$reused_change" ]]; then
    jj --quiet new "$reused_change"
  else
    jj --quiet new --after 'main' --message "$message"
  fi

  add_words "${words[@]}"

  if [[ -n "$(jj_find_change '@ & empty()')" ]]; then
    echo 'No changes' >&2
    jj --quiet undo '@'
  else
    jj --no-pager diff --revisions '@'

    if [[ -n "$reused_change" ]]; then
      jj --quiet squash
    fi

    if [[ -n "$(jj_find_change "$current_change")" ]]; then
      jj --quiet edit "$current_change"
    else
      jj --quiet new "$current_parent_change"
    fi
  fi
}

jj_available() {
  jj --ignore-working-copy 'root' 2>'/dev/null'
}

jj_find_change() {
  jj log --color 'never' --no-graph --limit '1' --revisions "$1" --template 'self.change_id()'
}

cd "${path%/*}"

if jj_available; then
  handle_jj
else
  handle_git
fi
