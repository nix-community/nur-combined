{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  mkUpdateScript,
}:
let
  versionData = lib.importJSON ./hashes.json;
  inherit (versionData) version;

  # Prebuilt release binaries; the crate is not packaged in nixpkgs.
  # nixpkgs system -> upstream release asset target triple.
  targets = {
    x86_64-linux = "x86_64-unknown-linux-gnu";
    aarch64-linux = "aarch64-unknown-linux-gnu";
  };

  system = stdenv.hostPlatform.system;
  target =
    targets.${system}
      or (throw "computer-use-linux: unsupported system ${system}");

  hash =
    versionData.hashes.${target}
      or (throw "computer-use-linux: no hash for ${target} in hashes.json");
in
stdenv.mkDerivation {
  pname = "computer-use-linux";
  inherit version;

  src = fetchurl {
    url = "https://github.com/agent-sh/computer-use-linux/releases/download/v${version}/computer-use-linux-${target}";
    inherit hash;
  };

  nativeBuildInputs = [ autoPatchelfHook ];
  buildInputs = [ stdenv.cc.cc.lib ];

  dontUnpack = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 $src $out/bin/computer-use-linux
    runHook postInstall
  '';

  passthru.updateScript = mkUpdateScript { name = "computer-use-linux"; };

  meta = {
    description = "MCP server and CLI to control a Linux desktop";
    homepage = "https://github.com/agent-sh/computer-use-linux";
    license = lib.licenses.mit;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    mainProgram = "computer-use-linux";
  };
}
