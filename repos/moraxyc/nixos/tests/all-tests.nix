{
  callPackage,
  ...
}:

{
  # keep-sorted start case=no numeric=yes
  airtrail = callPackage ./airtrail.nix { };
  antigravity-claude-proxy = callPackage ./antigravity-claude-proxy.nix { };
  artex = callPackage ./artex.nix { };
  dell-idrac-fan-controller = callPackage ./dell-idrac-fan-controller.nix { };
  ghostfolio = callPackage ./ghostfolio.nix { };
  tokenrouter = callPackage ./tokenrouter.nix { };
  ztnet = callPackage ./ztnet.nix { };
  # keep-sorted end
}
