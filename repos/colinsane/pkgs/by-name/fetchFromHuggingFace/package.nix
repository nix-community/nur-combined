{
  fetchgit,
  lib,
}:
{
  owner,
  repo,
  path,
  name ? path,
  rev,
  hash ? lib.fakeHash,
  ...
}@args: fetchgit (
  (lib.removeAttrs args [ "owner" "repo" "path" ]) // {
    inherit name rev hash;
    url = "https://huggingface.co/${owner}/${repo}";
    rootDir = path;
    fetchLFS = true;
  }
)
