_git-commit_message_custom() {
  git rev-parse --is-inside-work-tree &>'/dev/null' || return 0

  local descriptions=() messages=() result

  result="$(git diff --name-only --staged)"
  if [[ -n "$result" ]]; then
    messages=("${(@)^${(f)result}:t:r}: ")
    descriptions+=("${(@)^messages//:/\\:}:Scope")
  fi

  result="$(_git-commit_message_version-change)"
  if [[ -n "$result" ]]; then
    messages=("${(f)result}")
    descriptions+=("${(@)^messages//:/\\:}:Version change")
  fi

  _describe 'message' descriptions
}

_git-commit_message_version-change() {
  git diff \
    --staged \
    --word-diff='plain' \
    --word-diff-regex='[0-9]+(\.[0-9]+)*(-unstable[-0-9]*)?' \
  2>/dev/null \
  | sed --quiet --regexp-extended '
    # At file name
    \"^\+\+\+ i.*/([^/.]+)[^/]+$" {
      # Hold message part
      s//\1/
      h
    }

    # At version diff
    /^.*\[-(.*)-\]\{\+(.*)\+\}.*$/ {
      # Hold message part
      s//\1 → \2/
      H

      # Return message
      g
      s/\n/: /
      p
    }
  '
}

# TODO: Use `zstyle ':completion::complete:git-commit:message-option-*'` instead?
_git; functions -c _git-commit{,_original}; _git-commit() {
  _git-commit_original "$@"

  if [[ "$words[$((CURRENT - 1))]" == '--message' ]]; then
    _git-commit_message_custom
  fi
}
