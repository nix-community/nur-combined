{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  fcitx5,
  vulkan-loader,
  ...
}: let
  version = "0.0.9";
in
  stdenv.mkDerivation {
    pname = "fcitx5-hazkey";
    inherit version;

    src = fetchurl {
      url = "https://github.com/7ka-Hiira/fcitx5-hazkey/releases/download/${version}/fcitx5-hazkey-${version}-x86_64.tar.gz";
      hash = "sha256-WPJDxp5iHEVjsiMt9NhvxVQShYYRPa51gDwA0dG2H3I=";
    };

    buildInputs = [
      fcitx5
      vulkan-loader
      stdenv.cc.cc.lib
    ];
    nativeBuildInputs = [
      autoPatchelfHook
    ];

    patchPhase = ''
      runHook prePatch

      # fcitx5 does not search under /lib/x86_64-linux-gnu/
      # therefore it must be flattened to /lib/
      mv ./lib/x86_64-linux-gnu/* ./lib
      rmdir ./lib/x86_64-linux-gnu

      runHook postPatch
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out
      cp -r . $out/

      runHook postInstall
    '';

    meta = with lib; {
      homepage = "https://github.com/7ka-Hiira/fcitx5-hazkey";
      description = "Japanese input method for fcitx5, powered by azooKey engine";
      license = licenses.mit;
      maintainers = [];
      platforms = ["x86_64-linux"];
      # no main program because this is not executable
    };
  }
