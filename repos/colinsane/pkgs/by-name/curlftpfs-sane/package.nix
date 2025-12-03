# see also:
# - <https://github.com/jomat/curlftpfs/pull/2>
{
  curlftpfs,
  fetchFromGitea,
  fuse3,
  libbsd,
}:
(curlftpfs.override {
  fuse = fuse3;
}).overrideAttrs (upstream: {
  # my fork includes:
  # - per-operation timeouts (CURLOPT_TIMEOUT; would use CURLOPT_LOW_SPEED_TIME/CURLOPT_LOW_SPEED_LIMIT but they don't apply)
  #   - exit on timeout (so that one knows to abort the mount, instead of waiting indefinitely)
  # - support for "meta" keys found in /etc/fstab
  # - implements the fuse3 API. this means it also supports `-o drop_privileges`
  # - don't error on access to paths which contain symbols like ` ` or `%`.
  version = "0.9.2-unstable-2025-09-22";
  src = fetchFromGitea {
    domain = "git.uninsane.org";
    owner = "colin";
    repo = "curlftpfs";
    rev = "787ba1a3ca49ef40c2dc4c5a47bfbc89ea91e8b3";
    hash = "sha256-7NPQm36rsrkeC2ewwMuiw6sIYoArK+f/PD0AIC9Fglw=";
  };
  # `mount` clears PATH before calling the mount helper (see util-linux/lib/env.c),
  # so the traditional /etc/fstab approach of fstype=fuse and device = curlftpfs#URI doesn't work.
  # instead, install a `mount.curlftpfs` mount helper. this is what programs like `gocryptfs` do.
  postInstall = (upstream.postInstall or "") + ''
    ln -s curlftpfs $out/bin/mount.fuse.curlftpfs
    ln -s curlftpfs $out/bin/mount.curlftpfs
  '';

  buildInputs = (upstream.buildInputs or []) ++ [
    libbsd
  ];
})
