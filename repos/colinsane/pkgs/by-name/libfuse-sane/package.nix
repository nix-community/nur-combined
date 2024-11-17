{
  fuse3,
  makeBinaryWrapper,
}:
let
  patched = fuse3.overrideAttrs (upstream: {
    outputs = upstream.outputs ++ [ "sane" ];
    defaultOutput = "sane";
    patches = (upstream.patches or []) ++ [
      ./pass_fuse_fd.patch
    ];
    nativeBuildInputs = (upstream.nativeBuildInputs or []) ++ [
      makeBinaryWrapper
    ];
    # wrap so that it looks for mount helpers in /run/current-system/sw/bin,
    # and furthermore so that those mount helpers inherit the sandboxed wrappers in /run/current-system/sw/bin
    postInstall = (upstream.postInstall or "") + ''
      wrapProgram $bin/sbin/mount.fuse3 \
        --suffix PATH : /run/current-system/sw/bin
    '';
    postFixup = (upstream.postFixup or "") + ''
      ln -s $bin/bin/mount.fuse3 $bin/bin/mount.fuse3.sane
      moveToOutput bin/mount.fuse3.sane "$sane"
    '';
    meta = (upstream.meta or {}) // {
      mainProgram = "mount.fuse3.sane";
      description = ''
        provides `mount.fuse3.sane`, which behaves identically to `mount.fuse3` except
        it supports an additional mount flag, `-o pass_fuse_fd`.

        when mounting with `-o pass_fuse_fd`, `mount.fuse3.sane` opens the `/dev/fuse` device (which requires CAP_SYS_ADMIN),
        and then `exec`s the userspace implementation, which inherits this file descriptor.
        `mount.fuse3.sane` invokes the userspace implementation with the device argument set to something like `/dev/fd/3`, indicating which fd holds the fuse device.

        the aim of this flag is to provide a clear handoff point at which the filesystem may drop CAP_SYS_ADMIN.
        in this regard, it's much like `-o drop_privileges`, only it leaves the responsibility for that to the fs impl,
        in case the fs needs to preserve _other_ privileges besides CAP_SYS_ADMIN.
      '';
    };
  });
in patched.sane
