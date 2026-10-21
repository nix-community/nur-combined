{
  lib,
  fetchzip,
}: {
  owner,
  repo,
  tag,
  asset,
  githubBase ? "github.com",
  ...
} @ args: let
  passthruAttrs = lib.removeAttrs args ["owner" "repo" "tag" "asset" "githubBase"];
in
  fetchzip (
    passthruAttrs
    // {url = "https://${githubBase}/${owner}/${repo}/releases/download/${tag}/${asset}";}
  )
