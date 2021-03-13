{ pkgs }:

{
  clash-premium = pkgs.callPackage ./clash-premium { };
  godns = pkgs.callPackage ./godns { };
  dpt-rp1-py = pkgs.callPackage ./dpt-rp1-py { };
  activate-dpt = pkgs.callPackage ./activate-dpt { };
  musicbox = pkgs.callPackage ./musicbox { };
  trojan = pkgs.callPackage ./trojan { };
  vlmcsd = pkgs.callPackage ./vlmcsd { };
}
