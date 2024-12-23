{ fetchurl }:

{
  owner,
  repo,
  tag,
  name,
  ...
}@args:
let
  baseUrl = "https://github.com/${owner}/${repo}";
in
(
  fetchurl (
    {
      url = "${baseUrl}/releases/download/${tag}/${name}";
    }
    // removeAttrs args [
      "owner"
      "repo"
      "tag"
      "name"
    ]
  )
  // {
    meta.homepage = baseUrl;
  }
)
