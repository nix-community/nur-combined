{ pkgs, ... }:
{
  sane.programs.curlftpfs = {
    packageUnwrapped = pkgs.curlftpfs.overrideAttrs (upstream: {
      # my fork includes:
      # - per-operation timeouts (CURLOPT_TIMEOUT; would use CURLOPT_LOW_SPEED_TIME/CURLOPT_LOW_SPEED_LIMIT but they don't apply)
      #   - exit on timeout (so that one knows to abort the mount, instead of waiting indefinitely)
      # - support for "meta" keys found in /etc/fstab
      src = pkgs.fetchFromGitea {
        domain = "git.uninsane.org";
        owner = "colin";
        repo = "curlftpfs";
        rev = "0890d32e709b5a01153f00d29ed4c00299744f5d";
        hash = "sha256-M28PzHqEAkezQdtPeL16z56prwl3BfMZqry0dlpXJls=";
      };
      # `mount` clears PATH before calling the mount helper (see util-linux/lib/env.c),
      # so the traditional /etc/fstab approach of fstype=fuse and device = curlftpfs#URI doesn't work.
      # instead, install a `mount.curlftpfs` mount helper. this is what programs like `gocryptfs` do.
      postInstall = (upstream.postInstall or "") + ''
        ln -s curlftpfs $out/bin/mount.fuse.curlftpfs
        ln -s curlftpfs $out/bin/mount.curlftpfs
      '';
    });

    # TODO: try to sandbox this better? maybe i can have fuse (unsandboxed) invoke curlftpfs (sandboxed)?
    # - landlock gives EPERM
    # - bwrap just silently doesn't mount it, maybe because of setuid stuff around fuse?
    # sandbox.method = "capshonly";
    # sandbox.net = "all";
    # sandbox.capabilities = [
    #   "sys_admin"
    #   "sys_module"
    # ];
  };
}
