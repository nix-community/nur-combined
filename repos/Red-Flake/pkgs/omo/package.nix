# OmO (oh-my-openagent) 5.x: standalone `omo` agent harness built on senpi (a pi fork).
# Not in nixpkgs, so this repackages the upstream release binary.
# Update: bump `version`, then refresh the hash with
#   nix-prefetch-url --type sha256 https://github.com/code-yeongyu/oh-my-openagent/releases/download/v<version>/omo-linux-x64
{ lib, stdenv, fetchurl, autoPatchelfHook }:
stdenv.mkDerivation rec {
  pname = "omo";
  version = "5.1.70";

  src = fetchurl {
    url = "https://github.com/code-yeongyu/oh-my-openagent/releases/download/v${version}/omo-linux-x64";
    hash = "sha256-bct/NPbcbI/XLL9vCgTsgjh7E1gVHFsWDIMICLykjSo=";
  };

  dontUnpack = true;
  # Bun-compiled executables keep their JS payload appended to the ELF;
  # stripping would drop it.
  dontStrip = true;

  nativeBuildInputs = [ autoPatchelfHook ];
  buildInputs = [ stdenv.cc.cc.lib ];

  installPhase = ''
    runHook preInstall
    install -Dm755 $src $out/bin/omo
    runHook postInstall
  '';

  meta = {
    description = "OmO: multi-model coding agent harness built on pi";
    homepage = "https://github.com/code-yeongyu/oh-my-openagent";
    license = lib.licenses.unfree; # SUL-1.0
    mainProgram = "omo";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
