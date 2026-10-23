{
  lib,
  fetchurl,
  fetchzip,
}: {
  owner,
  repo,
  tag,
  asset,
  extract ? true,
  githubBase ? "github.com",
  ...
} @ args: let
  fetcher =
    if extract
    then fetchzip
    else fetchurl;

  passthruAttrs = lib.removeAttrs args ["owner" "repo" "tag" "asset" "extract" "githubBase"];
in
  fetcher (
    passthruAttrs
    // {url = "https://${githubBase}/${owner}/${repo}/releases/download/${tag}/${asset}";}
  )
