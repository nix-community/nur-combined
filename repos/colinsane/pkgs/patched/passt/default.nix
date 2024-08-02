{ passt }:
passt.overrideAttrs (upstream: {
  # substituteInPlace conf.c \
  #   --replace-fail 'if (*uid)' 'if (true)'
  #
  # isolation.c claims this:
  #   /* Since Linux 5.12, if we want to update /proc/self/uid_map to create
  #    * a mapping from UID 0, which only happens with pasta spawning a child
  #    * from a non-init user namespace (pasta can't run as root), we need to
  #    * retain CAP_SETFCAP too.
  #    * We also need to keep CAP_SYS_PTRACE in order to join an existing netns
  #    * path under /proc/$pid/ns/net which was created in the same userns.
  #    */
  # but in fact, pasta CAN run as root -- if passed the `--runas 0` argument.

  postPatch = (upstream.postPatch or "") + ''
    substituteInPlace isolation.c \
      --replace-fail 'if (!ns_is_init() && !geteuid())' 'if (!geteuid())'
  '';

  passthru = (upstream.passthru or {}) // {
    unpatched = passt;
  };
})
