# hf.co rate limits: <https://huggingface.co/docs/hub/rate-limits>
# - `/resolve` http endpoints are the least restricted (i.e. http download of .model files)
# - API queries are more heavily rate-limited
# but in fact, we rarely get rate limited: the occasional bad perf seems to be some faulty connection-level state.
# - 1 in 5 requests gets stuck at 1 MB/s, until completion.
# - spin up an identical request on another thread and you'll get 50 MB/s -- even as that 1 MB/s connection continues.
# - control for DNS resolutions (`--connect-to us.aws.cdn.hf.co:...`, etc) => does not fix.
# - maybe it's some specific internal cloudfront node? bad TCP state, maybe around congestion control? who knows.
# `aria2c --max-connection-per-server 4` seems to overcome this and keep a steady 50 MB/s.
#   4 is what `aria2c --help` recommended -- i haven't tuned it.
#
#
### THE INFORMATION BELOW IS LIKELY IRRELEVANT ###
# hf downloaders:
# - hfd.sh: <https://gist.github.com/padeoe/697678ab8e528b85a2a7bddafea1fa4f#file-hfd-sh>
# - <https://github.com/bughoho/hfdownloader>
#   - git + aria2 for fast multi-mirror downloads (finding mirrors is left to the reader)
#
# ways/places to download model files:
# - <https://huggingface.co>
#   - observed: 5 MB/s average, highly variable within a DL but always averages 5 MB/s over the whole DL.
#   - set `HF_TOKEN` to enable higher rate limits
# - <https://hf-mirror.net>: mirrors API, http downloads, git and git-lfs
#   - calls itself a "streaming proxy"
# - <https://huffingface.co/>: drop-in replacement for the ~300 most popular models, http only (no `git clone`)
#   - observed: 13 - 30 MB/s
# - <https://modelscope.cn>: mirrors hf.co API and repos
#   - their mirroring process recreates the git repo though. so one would need to specify a separate `rev` for modelscope v.s. hf.
#     or maybe try mirroring at the lfs level instead
#   - observed: steady 12 MB/s DL
# - <https://pirateface.co>: reuses hf.co ${owner}/${repo} namespace, but distributes models via bittorrent
#   - most models have 0 seeders; your DL will never complete.
# - <https://llama.garden/>: like pirateface, but includes web seeds
# - <https://ai.gitcode.com/hf_mirrors/>: mirrors hf.co repos.
{
  fetchgit,
  git-lfs-agent-aria2,
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
}@args:
fetchgit (
  (lib.removeAttrs args [
    "owner"
    "repo"
    "path"
  ])
  // {
    inherit name rev hash;
    url = "https://huggingface.co/${owner}/${repo}";
    rootDir = path;
    fetchLFS = true;
    nativeBuildInputs = (args.nativeBuildInputs or [ ]) ++ [ git-lfs-agent-aria2 ];
  }
)
