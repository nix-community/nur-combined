{ lib, fetchurl, system, stdenv }:
let
  systemInfo = lib.systems.elaborate system;
  archMapping = {
    x86_64 = "amd64";
    aarch64 = "arm64";
    armv7l = "armv7";
  };

  arch = archMapping."${systemInfo.uname.processor}";
  os = lib.toLower "${systemInfo.uname.system}";
in 
stdenv.mkDerivation rec {
  pname = "talosctl";
  version = "1.0.0";

  src = fetchurl {
    url = "https://github.com/siderolabs/talos/releases/download/v1.0.0/talosctl-${os}-${arch}";
    sha256 = "1c2d5p0mnpq380d4py9hf46784kgy304yjvbzdy81fwwh2nrf9j6";
  };

  phases = ["installPhase"];

  installPhase = ''
    mkdir -p "$out/bin"
    cp $src "$out/bin/talosctl"
    chmod 777 "$out/bin/talosctl"
  '';

  dontPatchELF = true;
  meta = with lib; {
    description = "The Kubernetes Operating System";
    homepage    = "https://www.talos.dev/";
    license     = licenses.mpl20;
    platforms   = [
      "aarch64-darwin"
      "aarch64-linux"
      "armv7l-darwin"
      "x86_64-darwin"
      "x86_64-linux"
    ];
  };
}
