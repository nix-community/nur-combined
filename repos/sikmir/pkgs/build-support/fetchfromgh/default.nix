{ fetchurl }:

{ owner, repo, version, name, ... } @ args:

(
  fetchurl (
    {
      url = "https://github.com/${owner}/${repo}/releases/download/${version}/${name}";
    } // removeAttrs args [ "owner" "repo" "version" "name" ]
  )
)
