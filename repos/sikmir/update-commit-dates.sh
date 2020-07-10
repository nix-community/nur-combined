#!/usr/bin/env nix-shell
#! nix-shell -i bash -p curl jq moreutils

# heredoc variables
typeset \
  commit_dates_filter='' \
  commit_dates_query='' \


IFS='' read -r -d '' commit_dates_query <<'EOF' # vim:ft=jq
def repoField($alias):
  "\($alias): repository(owner: \(.owner | @json), name: \(.repo | @json)) { " +
    "object(expression: \(.rev | @json)) { ...go } }";

def build_query:
"fragment go on GitObject { ... on Commit { committedDate } }

query CommitDates {
  " + (map(.key as $alias | .value |
    select(has("owner") and has("repo")) |
      repoField($alias | gsub("-"; "_"))
  ) | join("\n  ")) + "
}";

{ query: to_entries | build_query }
EOF

IFS='' read -r -d '' commit_dates_filter <<'EOF' # vim:ft=jq
.data | with_entries(
  .key |= gsub("_"; "-") |
  .value |= { date: .object.committedDate }
) as $overrides | $sources[] * $overrides
EOF

set -o errexit -o errtrace -o nounset -o pipefail
shopt -s inherit_errexit

curl 'https://api.github.com/graphql' \
    -H "Authorization: bearer $GITHUB_TOKEN" \
    --data-binary "$(jq "${commit_dates_query}" nix/sources.json)" | \
  jq -S --indent 4 "${commit_dates_filter}" \
    --slurpfile sources nix/sources.json | \
  sponge nix/sources.json

# vim:et:ft=sh:sw=2:tw=78
