let
  defaultShas = {
    "x86_64-linux" = "sha256-MA6wZj/fGCbdNMsKcjMcxWJCgwz1EAtpEAMnqteanEQ=";
    "x86_64-darwin" = "sha256-zEYLpTR/EbG6p5Nymp1HUxHFJfKb4O3rPUhoFrThX5o=";
  };
in { lib, fetchurl, system, stdenvNoCC, version ? "1.0.5"
, sha256 ? defaultShas.${system} }:
let
  archMapping = {
    x86_64 = "amd64";
    aarch64 = "arm64";
    armv7l = "armv7";
  };
  systemInfo = lib.systems.elaborate system;
  arch = archMapping."${systemInfo.uname.processor}";
  os = lib.toLower "${systemInfo.uname.system}";
in stdenvNoCC.mkDerivation rec {
  inherit version;
  pname = "talosctl-bin";
  src = fetchurl {
    inherit sha256;
    url =
      "https://github.com/siderolabs/talos/releases/download/v${version}/talosctl-${os}-${arch}";
  };
  phases = [ "installPhase" ];

  installPhase = ''
    mkdir -p "$out/bin"
    cp $src "$out/bin/talosctl"
    chmod 777 "$out/bin/talosctl"
  '';

  dontPatchELF = true;
  meta = with lib; {
    description = "The Kubernetes Operating System";
    homepage = "https://www.talos.dev/";
    license = licenses.mpl20;
    mainProgram = "talosctl";
    platforms = [
      "aarch64-darwin"
      "aarch64-linux"
      "armv7l-darwin"
      "x86_64-darwin"
      "x86_64-linux"
    ];
  };
}
