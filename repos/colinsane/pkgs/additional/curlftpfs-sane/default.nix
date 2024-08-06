{
  curlftpfs,
  fetchFromGitea,
  fuse3,
}:
(curlftpfs.override {
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
    rev = "fuse3";
    hash = "sha256-QwGbQuriNwnZscnYBEVp3Td6/ifiA8rtQcvtvmTnpbU=";
  };
  # `mount` clears PATH before calling the mount helper (see util-linux/lib/env.c),
  # so the traditional /etc/fstab approach of fstype=fuse and device = curlftpfs#URI doesn't work.
  # instead, install a `mount.curlftpfs` mount helper. this is what programs like `gocryptfs` do.
  postInstall = (upstream.postInstall or "") + ''
    ln -s curlftpfs $out/bin/mount.fuse.curlftpfs
    ln -s curlftpfs $out/bin/mount.curlftpfs
  '';
})
