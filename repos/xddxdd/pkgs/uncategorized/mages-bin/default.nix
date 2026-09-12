{
  appimageTools,
  fetchurl,
  lib,
  openjdk25,
  stdenv,
}:
let
  sources = builtins.fromJSON (builtins.readFile ./sources.json);

  arch = sources.${stdenv.hostPlatform.system};

  contents = appimageTools.extract {
    pname = "mages-bin";
    inherit (arch) version;
    src = fetchurl {
      inherit (arch) url hash;
    };
    postExtract = ''
      chmod -R u+w "$out/lib/runtime"
      rm -rf "$out/lib/runtime"
      ln -s ${openjdk25.home} "$out/lib/runtime"
    '';
  };
in
appimageTools.wrapAppImage {
  pname = "mages-bin";
  inherit (arch) version;
  inherit contents;

  extraInstallCommands = ''
    install -Dm644 ${contents}/io.github.mlm_games.mages.desktop $out/share/applications/mages-bin.desktop
    substituteInPlace $out/share/applications/mages-bin.desktop \
      --replace-fail 'Exec=Mages' 'Exec=mages-bin'
    install -Dm644 ${contents}/mages.png $out/share/pixmaps/mages.png
  '';

  meta = {
    maintainers = [ lib.maintainers.xddxdd ];
    description = "Experimental Matrix chat client built with Compose Multiplatform and matrix-rust-sdk";
    homepage = "https://github.com/mlm-games/Mages";
    license = lib.licenses.agpl3Only;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    mainProgram = "mages-bin";
  };
}
