{ extraLgArgs ? {}
, callPackageWindows ? pkgsWindows.callPackage, pkgsWindows ? pkgsCross.mingwW64, pkgsCross ? {}
, enableNvfbc ? false, extraNvfbcArgs ? {}
, optimizeForArch ? null
}: callPackageWindows ./host.nix ({
  inherit enableNvfbc optimizeForArch;
  nvidia-capture-sdk = callPackageWindows ../nvidia-capture-sdk.nix extraNvfbcArgs;
} // extraLgArgs)
