{ path, callPackage, fetchurl, krb5 }:
let
  executableName = "openvscode-server";
  base =
    callPackage (import (path + "/pkgs/applications/editors/vscode/generic.nix")) rec {
      version = "1.82.2";
      pname = "openvscode-server";
      src = fetchurl {
        url = "https://github.com/gitpod-io/openvscode-server/releases/download/openvscode-server-v${version}/openvscode-server-v${version}-linux-x64.tar.gz";
        hash = "sha256-4ht/rdJ08GiapXX3xGCN4/AYpMGYMeYGs042QdVQS3s=";
      };
      inherit executableName;
      longName = "OpenVSCode Server";
      shortName = "openvscode-server";
      commandLineArgs = "";
      sourceRoot = "openvscode-server-v1.82.2-linux-x64";
      updateScript = null;
      meta = {
        mainProgram = executableName;
      };
    };
in
base.overrideAttrs (old: {
  postPatch = "";
  installPhase = ''
    runHook preInstall

    mkdir -p "$out/lib/vscode" "$out/bin"
    cp -r ./* "$out/lib/vscode"
    ln -s "$out/lib/vscode/bin/${executableName}" "$out/bin/${executableName}"

    runHook postInstall
  '';
  postFixup = "";
  buildInputs = old.buildInputs ++ [ krb5 ];
})
