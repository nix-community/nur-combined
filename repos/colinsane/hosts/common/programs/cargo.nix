{ ... }:
{
  sane.programs.cargo = {
    #v XXX(2025-02-23): normal `cargo` fails to build for cross (temporarily?). use prebuilt instead.
    # NOT easy to debug/fix. git bisect pins this between ceba2c6c3b (good) and 62a28e5a3d (bad)
    # packageUnwrapped = pkgs.rust.packages.prebuilt.cargo;

    buildCost = 1; # 2.5 GiB closure

    persist.byStore.plaintext = [ ".cargo" ];
    # probably this sandboxing is too restrictive; i'm sandboxing it for rust-analyzer / neovim LSP
    sandbox.whitelistPwd = true;
    sandbox.net = "all";
    sandbox.extraHomePaths = [ "dev" "ref" ];
  };
}
