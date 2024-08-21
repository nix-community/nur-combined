{
  curl,
  curlftpfs,
  fetchpatch,
  fetchFromGitea,
  fuse3,
}:
(curlftpfs.override {
  curl = curl.overrideAttrs (base: {
    patches = (base.patches or []) ++ [
      (fetchpatch {
        # fix regression in curl 8.8.0 -> 8.9.0 which broke curlftpfs
        url = "https://github.com/curl/curl/pull/14629.diff";
        name = "setopt: allow CURLOPT_INTERFACE to be set to NULL";
        hash = "sha256-cpiw0izhFY74y8xa7KEoQOtD79GBIfrm1hU3sLrObJg=";
      })
    ];
  });
  fuse = fuse3;
}).overrideAttrs (upstream: {
  # my (master branch) fork includes:
  # - per-operation timeouts (CURLOPT_TIMEOUT; would use CURLOPT_LOW_SPEED_TIME/CURLOPT_LOW_SPEED_LIMIT but they don't apply)
  #   - exit on timeout (so that one knows to abort the mount, instead of waiting indefinitely)
  # - support for "meta" keys found in /etc/fstab
  # my (fuse3 branch) fork includes the above plus:
  # - implements the fuse3 API. this means it also supports `-o drop_privileges`
  src = fetchFromGitea {
    domain = "git.uninsane.org";
    owner = "colin";
    repo = "curlftpfs";
    rev = "master";
    hash = "sha256-bqkRHV4d1y349yIHAtXPMlfWciVCH/geW73id8aJwUs=";
  };
  # `mount` clears PATH before calling the mount helper (see util-linux/lib/env.c),
  # so the traditional /etc/fstab approach of fstype=fuse and device = curlftpfs#URI doesn't work.
  # instead, install a `mount.curlftpfs` mount helper. this is what programs like `gocryptfs` do.
  postInstall = (upstream.postInstall or "") + ''
    ln -s curlftpfs $out/bin/mount.fuse.curlftpfs
    ln -s curlftpfs $out/bin/mount.curlftpfs
  '';
})
