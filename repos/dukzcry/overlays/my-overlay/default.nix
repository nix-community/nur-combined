self: super:
let
  unstable = import <nixos-unstable> { config.allowUnfree = true; };
in {
  haskellPackages = super.haskellPackages.override {
    overrides = hsSelf: hsSuper: {
      hakyll-images = self.haskell.lib.unmarkBroken hsSuper.hakyll-images;
    };
  };
  inherit (unstable)
    zoom-us # https://github.com/NixOS/nixpkgs/pull/103485
    bambootracker;
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
  # https://github.com/qutebrowser/qutebrowser/pull/5917
  qutebrowser = unstable.qutebrowser.override {
    python3 = super.python3.override {
      packageOverrides = selfx: superx: {
        pyqtwebengine = superx.pyqtwebengine.overridePythonAttrs (oldAttrs: rec {
          src = superx.pythonPackages.fetchPypi {
            pname = "PyQtWebEngine";
            version = "5.15.2";
            sha256 = "0d56ak71r14w4f9r96vaj34qcn2rbln3s6ildvvyc707fjkzwwjd";
          };
        });
      };
    };
  };
}
