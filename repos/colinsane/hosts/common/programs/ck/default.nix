# semantic code search; like `coderag` but indexes automatically.
# TODO: download model in nix; remove sandbox.net.
# TODO: store embeddings in a XDG dir, not ./.ck
{ ... }:
{
  sane.programs.ck = {
    sandbox.whitelistPwd = true;
    sandbox.net = "clearnet";  # for model downloads
    persist.byStore.private = [
      ".cache/ck"
    ];
  };
}
