self: super:
let
  unstable = import <nixos-unstable> { config.allowUnfree = true; };
in {
  # https://github.com/NixOS/nixpkgs/issues/98009
  #qt515 = super.qt515.overrideScope' (selfx: superx: {
  #  qtbase = superx.qtbase.overrideAttrs (old: {
  #    patches = (old.patches or []) ++ super.lib.optional (builtins.compareVersions super.qt515.qtbase.version "5.15.0" == 0) [
  #      ./7218665.diff
  #    ];
  #  });
  #});
  libsForQt512 = super.libsForQt512 // {
    adwaita-qt = with super; libsForQt512.callPackage <nixpkgs/pkgs/data/themes/adwaita-qt> {
      mkDerivation = stdenv.mkDerivation;
    };
  };
  libsForQt514 = super.libsForQt514 // {
    adwaita-qt = with super; libsForQt514.callPackage <nixpkgs/pkgs/data/themes/adwaita-qt> {
      mkDerivation = stdenv.mkDerivation;
    };
  };
  haskellPackages = super.haskellPackages.override {
    overrides = hsSelf: hsSuper: {
      hakyll-images = self.haskell.lib.unmarkBroken hsSuper.hakyll-images;
    };
  };
  # https://github.com/NixOS/nixpkgs/pull/103485
  inherit (unstable) zoom-us;
  steam-wrapper = with super; writeShellScriptBin "steam-wrapper" ''
    export __NV_PRIME_RENDER_OFFLOAD=1
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export __VK_LAYER_NV_optimus=NVIDIA_only
    export LANG=en_US.UTF8
    export LC_ALL=en_US.UTF8
    ${apulse}/bin/apulse "$@"
  '';
  ArchiSteamFarm = with super; (ArchiSteamFarm.override {
    dotnetCorePackages = dotnetCorePackages // {
      aspnetcore_3_1 = unstable.dotnetCorePackages.aspnetcore_5_0;
    };
  }).overrideAttrs (oldAttrs: rec {
    version = "5.0.1.2";
    src = fetchurl {
      url = "https://github.com/JustArchiNET/ArchiSteamFarm/releases/download/${version}/ASF-generic.zip";
      sha256 = "0wczibyv8pwjcd4bxpw70w99ayyii0brfc180cdxp8cznn7p8vxh";
    };
  });
}
