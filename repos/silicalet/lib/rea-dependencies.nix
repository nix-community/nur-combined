{ pkgs }:

let
  groups = {
    native = [ pkgs.ghidra ];
    android = [
      pkgs.jadx
      pkgs.jdk
      pkgs.android-tools
    ];
    browser = [ pkgs.chromium ];
    packets = [
      pkgs.wireshark-cli
      pkgs.util-linux
    ];
    firmware = [
      pkgs.binwalk
      pkgs.unblob
      pkgs.util-linux
    ];
    captures = [ pkgs.mitmproxy ];
  };
in
groups
// {
  # WABT and sigrok-cli in our pinned nixpkgs do not match REA's required
  # versions. Do not include incompatible providers in the default list.
  all = pkgs.lib.unique (pkgs.lib.concatLists (builtins.attrValues groups));
}
