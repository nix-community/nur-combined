{ fetchurl }:

{
  owner,
  repo,
  version,
  name,
  ...
}@args:
let
  baseUrl = "https://github.com/${owner}/${repo}";
in
(
  fetchurl (
    {
      url = "${baseUrl}/releases/download/${version}/${name}";
    }
    // removeAttrs args [
      "owner"
      "repo"
      "version"
      "name"
    ]
  )
  // {
    meta.homepage = baseUrl;
  }
)
