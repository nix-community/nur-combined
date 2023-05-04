{ fuse, gocryptfs, util-linux, lib }:

(gocryptfs.overrideAttrs (upstream: {
  # XXX `su colin` hangs when pam_mount tries to mount a gocryptfs system
  # unless `logger` (util-linux) is accessible from gocryptfs.
  # this is surprising: the code LOOKS like it's meant to handle logging failures.
  # propagating util-linux through either `environment.systemPackages` or `security.pam.mount.additionalSearchPaths` DOES NOT WORK.
  #
  # TODO: see about upstreaming this
  #
  # additionally, we need /run/wrappers/bin EXPLICITLY in PATH, for when we run not as root.
  # but we want to keep `fuse` for when we ARE running as root -- particularly during an activation script BEFORE the wrappers exist.
  postInstall = ''
    wrapProgram $out/bin/gocryptfs \
      --suffix PATH : ${lib.makeBinPath [ util-linux ]} \
      --suffix PATH : /run/wrappers/bin \
      --suffix PATH : ${lib.makeBinPath [ fuse ]}
    ln -s $out/bin/gocryptfs $out/bin/mount.fuse.gocryptfs
  '';
}))
