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
}: fetchgit {
  inherit name rev hash;
  url = "https://huggingface.co/${owner}/${repo}";
  rootDir = path;
  fetchLFS = true;
}
