final: prev: {
  chrysalis = let
    pname = "chrysalis";
    version = "0.11.3";
    name = "${pname}-${version}-binary";
  in prev.appimageTools.wrapAppImage rec {
    inherit name;

    src = prev.appimageTools.extract {
      inherit name;
      src = prev.fetchurl {
        url = "https://github.com/keyboardio/${pname}/releases/download/v${version}/${pname}-${version}.AppImage";
        sha256 = "sha256-N0M1lZvPKAT+UXZgn68DaDupzXJupcOE06gFxKP6W0o=";
      };
    };

    multiPkgs = null;
    extraPkgs = p: (prev.appimageTools.defaultFhsEnvArgs.multiPkgs p) ++ [
      p.glib
    ];

    # Also expose the udev rules here, so it can be used as:
    #   services.udev.packages = [ pkgs.chrysalis ];
    # to allow non-root modifications to the keyboards.

    extraInstallCommands = ''
      mv $out/bin/${name} $out/bin/${pname}
      mkdir -p $out/lib/udev/rules.d
      ln -s \
        --target-directory=$out/lib/udev/rules.d \
        ${src}/resources/static/udev/60-kaleidoscope.rules
    '';
  };
}
