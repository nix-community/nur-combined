{
  writeShellScript,
  curl,
  jq,
  coreutils,
}:

let
  # --- GitHub 适配器 ---

  # 追踪特定分支或 Commit，生成 unstable 版本号
  githubGit =
    {
      owner,
      repo,
      ref ? "main",
    }:
    writeShellScript "fetch-github-${owner}-${repo}-git-meta" ''
      set -euo pipefail
      [ -n "''${GITHUB_TOKEN:-}" ] && AUTH_HEADER=(-H "Authorization: Bearer $GITHUB_TOKEN") || AUTH_HEADER=()

      sha=$(${curl}/bin/curl -sS -L --fail --retry 3 "''${AUTH_HEADER[@]}" \
        "https://api.github.com/repos/${owner}/${repo}/commits/${ref}" | ${jq}/bin/jq -r '.sha')

      if [ -z "$sha" ] || [ "$sha" = "null" ]; then
        echo "Error: Failed to fetch GitHub commit SHA" >&2
        exit 1
      fi

      short_sha=''${sha:0:9}
      date=$(${coreutils}/bin/date -u +%Y%m%d)

      ${jq}/bin/jq -n --arg v "0-unstable-$date-$short_sha" --arg r "$sha" '{version: $v, rev: $r}'
    '';

  # 获取最新 Release 并剥离版本号前缀 'v'
  githubRelease =
    { owner, repo }:
    writeShellScript "fetch-github-${owner}-${repo}-release-meta" ''
      set -euo pipefail
      [ -n "''${GITHUB_TOKEN:-}" ] && AUTH_HEADER=(-H "Authorization: Bearer $GITHUB_TOKEN") || AUTH_HEADER=()

      ${curl}/bin/curl -sS -L --fail --retry 3 "''${AUTH_HEADER[@]}" \
        "https://api.github.com/repos/${owner}/${repo}/releases/latest" | ${jq}/bin/jq '
          if .tag_name then {version: (.tag_name | ltrimstr("v"))}
          else {error: "No GitHub release found"} end
        '
    '';

  # 获取最新 Tag
  githubTag =
    { owner, repo }:
    writeShellScript "fetch-github-${owner}-${repo}-tag-meta" ''
      set -euo pipefail
      [ -n "''${GITHUB_TOKEN:-}" ] && AUTH_HEADER=(-H "Authorization: Bearer $GITHUB_TOKEN") || AUTH_HEADER=()

      ${curl}/bin/curl -sS -L --fail --retry 3 "''${AUTH_HEADER[@]}" \
        "https://api.github.com/repos/${owner}/${repo}/tags" | ${jq}/bin/jq '
          if (length > 0) then {version: (.[0].name | ltrimstr("v"))}
          else {error: "No GitHub tags found"} end
        '
    '';

  # --- GitLab 适配器 ---

  # 追踪 GitLab 分支或 Commit
  gitlabGit =
    {
      owner,
      repo,
      ref ? "main",
      domain ? "gitlab.com",
    }:
    writeShellScript "fetch-gitlab-${owner}-${repo}-git-meta" ''
      set -euo pipefail
      encoded_path=$(echo "${owner}/${repo}" | sed 's/\//%2F/g')
      [ -n "''${GITLAB_TOKEN:-}" ] && AUTH_HEADER=(-H "PRIVATE-TOKEN: $GITLAB_TOKEN") || AUTH_HEADER=()

      sha=$(${curl}/bin/curl -sS -L --fail --retry 3 "''${AUTH_HEADER[@]}" \
        "https://${domain}/api/v4/projects/$encoded_path/repository/commits/${ref}" | ${jq}/bin/jq -r '.id')

      if [ -z "$sha" ] || [ "$sha" = "null" ]; then
        echo "Error: Failed to fetch GitLab commit SHA" >&2
        exit 1
      fi

      short_sha=''${sha:0:9}
      date=$(${coreutils}/bin/date -u +%Y%m%d)
      ${jq}/bin/jq -n --arg v "0-unstable-$date-$short_sha" --arg r "$sha" '{version: $v, rev: $r}'
    '';

  # 获取 GitLab 最新 Tag
  gitlabTag =
    {
      owner,
      repo,
      domain ? "gitlab.com",
    }:
    writeShellScript "fetch-gitlab-${owner}-${repo}-tag-meta" ''
      set -euo pipefail
      encoded_path=$(echo "${owner}/${repo}" | sed 's/\//%2F/g')
      [ -n "''${GITLAB_TOKEN:-}" ] && AUTH_HEADER=(-H "PRIVATE-TOKEN: $GITLAB_TOKEN") || AUTH_HEADER=()

      ${curl}/bin/curl -sS -L --fail --retry 3 "''${AUTH_HEADER[@]}" \
        "https://${domain}/api/v4/projects/$encoded_path/repository/tags" | ${jq}/bin/jq '
          if (length > 0) then {version: (.[0].name | ltrimstr("v"))}
          else {error: "No GitLab tags found"} end
        '
    '';

  # --- Gitea / Codeberg 适配器 ---

  # 追踪 Gitea 分支或 Commit
  giteaGit =
    {
      owner,
      repo,
      ref ? "main",
      domain ? "codeberg.org",
    }:
    writeShellScript "fetch-gitea-${owner}-${repo}-git-meta" ''
      set -euo pipefail
      [ -n "''${GITEA_TOKEN:-}" ] && AUTH_HEADER=(-H "Authorization: token $GITEA_TOKEN") || AUTH_HEADER=()

      sha=$(${curl}/bin/curl -sS -L --fail --retry 3 "''${AUTH_HEADER[@]}" \
        "https://${domain}/api/v1/repos/${owner}/${repo}/commits/${ref}" | ${jq}/bin/jq -r '.sha')

      if [ -z "$sha" ] || [ "$sha" = "null" ]; then
        echo "Error: Failed to fetch Gitea/Codeberg commit SHA" >&2
        exit 1
      fi

      short_sha=''${sha:0:9}
      date=$(${coreutils}/bin/date -u +%Y%m%d)
      ${jq}/bin/jq -n --arg v "0-unstable-$date-$short_sha" --arg r "$sha" '{version: $v, rev: $r}'
    '';

  # 获取 Gitea 最新 Release
  giteaRelease =
    {
      owner,
      repo,
      domain ? "codeberg.org",
    }:
    writeShellScript "fetch-gitea-${owner}-${repo}-release-meta" ''
      set -euo pipefail
      [ -n "''${GITEA_TOKEN:-}" ] && AUTH_HEADER=(-H "Authorization: token $GITEA_TOKEN") || AUTH_HEADER=()

      ${curl}/bin/curl -sS -L --fail --retry 3 "''${AUTH_HEADER[@]}" \
        "https://${domain}/api/v1/repos/${owner}/${repo}/releases?limit=1" | ${jq}/bin/jq '
          if (length > 0) then {version: (.[0].tag_name | ltrimstr("v"))}
          else {error: "No Gitea/Codeberg release found"} end
        '
    '';

in
{
  inherit githubGit githubRelease githubTag;
  inherit gitlabGit gitlabTag;
  inherit giteaGit giteaRelease;
}
