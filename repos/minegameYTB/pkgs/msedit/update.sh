#!/usr/bin/env bash

set -euo pipefail

version="1.0.0"
systems=("x86_64-linux" "aarch64-linux")

declare -A suffixes=(
  ["x86_64-linux"]="x86_64-linux-gnu"
  ["aarch64-linux"]="aarch64-linux-gnu"
)

declare -A hashes

for system in "${systems[@]}"; do
  suffix="${suffixes[$system]}"
  url="https://github.com/microsoft/edit/releases/download/v${version}/edit-${version}-${suffix}.xz"
  echo "Fetching hash for $system..."
  hashes[$system]=$(nix-prefetch-url --type sha256 "$url")
done

cat > default.nix <<'EOF'
### This derivation is generated by update.sh (root of this directory), made changes here

{ lib, stdenvNoCC, fetchurl, xz, autoPatchelfHook }:

let
  system = stdenvNoCC.hostPlatform.system;
  archMap = {
    "x86_64-linux" = "x86_64-linux-gnu";
    "aarch64-linux" = "aarch64-linux-gnu";
  };
  hashMap = {
    "x86_64-linux" = "__HASH_X86_64__";
    "aarch64-linux" = "__HASH_AARCH64__";
  };
  archSuffix = archMap.${system} or (throw "Unsupported system: ${system}");
  sha256 = hashMap.${system} or (throw "No sha256 for system: ${system}");
in

stdenvNoCC.mkDerivation rec {
  pname = "msedit";
  version = "__VERSION__";

  src = fetchurl {
    url = "https://github.com/microsoft/edit/releases/download/v${version}/edit-${version}-${archSuffix}.xz";
    inherit sha256;
  };

  dontUnpack = true;
  dontBuild = true;
  dontConfigure = true;
  sourceRoot = ".";

  nativeBuildInputs = [ xz autoPatchelfHook ];

  installPhase = ''
    mkdir -p $out/bin
    unxz -c $src > $out/bin/${pname}
    chmod +x $out/bin/${pname}
  '';

  meta = with lib; {
    description = "A simple editor for simple needs.";
    homepage = "https://github.com/microsoft/edit";
    license = licenses.mit;
    mainProgram = "msedit";
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
  };
}
EOF

### Replace placeholder by variable content 
sed -i "s|__VERSION__|${version}|g" default.nix
sed -i "s|__HASH_X86_64__|${hashes[x86_64-linux]}|g" default.nix
sed -i "s|__HASH_AARCH64__|${hashes[aarch64-linux]}|g" default.nix

echo "default.nix updated!"

