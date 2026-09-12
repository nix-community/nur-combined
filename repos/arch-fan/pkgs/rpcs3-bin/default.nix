{
  lib,
  appimageTools,
  fetchurl,
  writeShellApplication,
  curl,
  jq,
  nix,
  perl,
}:

let
  pname = "rpcs3";
  version = "0.0.42-19984";

  commit = "961c86fbbf4a9dd0d717f45fd0c330cecbdccf70";
  shortCommit = "961c86fb";

  src = fetchurl {
    url = "https://github.com/RPCS3/rpcs3-binaries-linux/releases/download/build-${commit}/rpcs3-v${version}-${shortCommit}_linux64.AppImage";
    hash = "sha256-IpJaH5NbqVFyMJ7YuSU773P+7boDVEqy4tW/3AtaW0c=";
  };

  appimageContents = appimageTools.extractType2 {
    inherit pname version src;
  };

  updateScript = writeShellApplication {
    name = "update-rpcs3-bin";

    runtimeInputs = [
      curl
      jq
      nix
      perl
    ];

    text = builtins.readFile ./update.sh;
  };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    install -Dm444 \
      ${appimageContents}/rpcs3.desktop \
      $out/share/applications/rpcs3.desktop
  '';

  passthru.updateScript = [
    (lib.getExe updateScript)
    "pkgs/rpcs3-bin/default.nix"
  ];

  meta = {
    description = "PlayStation 3 emulator and debugger";
    homepage = "https://rpcs3.net/";
    license = lib.licenses.gpl2Only;
    mainProgram = "rpcs3";
    platforms = [ "x86_64-linux" ];
  };
}
