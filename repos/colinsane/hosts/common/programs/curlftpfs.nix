{ pkgs, ... }:
{
  sane.programs.curlftpfs = {
    packageUnwrapped = pkgs.curlftpfs-sane;
    # TODO: try to sandbox this better? maybe i can have fuse (unsandboxed) invoke curlftpfs (sandboxed)?
    # traditional way is via `-o drop_privileges`, supported by fuse3 only.

    # sandbox.method = "capshonly";
    # sandbox.net = "all";
    # sandbox.capabilities = [
    #   "sys_admin"
    #   "sys_module"
    # ];
  };
}
