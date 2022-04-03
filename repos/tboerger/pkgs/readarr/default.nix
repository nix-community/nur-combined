{ lib, stdenv, fetchurl, mono, makeWrapper, dotnetCorePackages, icu, sqlite, openssl, nixosTests }:

let
  os = if stdenv.isDarwin then "osx" else "linux";
  arch = {
    x86_64-linux = "x64";
    aarch64-linux = "arm64";
    x86_64-darwin = "x64";
    aarch64-darwin = "arm64";
  }."${stdenv.hostPlatform.system}" or (throw "Unsupported system: ${stdenv.hostPlatform.system}");

  hash = {
    x64-linux_hash = "sha256-GC/hwoQkzqkTOQrdO40C10K1MNmlcn9XTwwWHo96l4Q=";
    arm64-linux_hash = "sha256-x8BnAuDWudbSKrtmXm6PFeFxNrfVYJot1r7VyB6YuWs=";
    x64-osx_hash = "sha256-P5JeiPCJjoWGei6a8LZToShcRzAZQP73/+VpRydyTPs=";
    arm64-osx_hash = "sha256-fRXTIjvmxo7DueKt8NoWhxDIakx5MtHwFF5FKg3nKN0=";
  }."${arch}-${os}_hash";

in stdenv.mkDerivation rec {
  pname = "readarr";
  version = "0.1.0.1248";

  src = fetchurl {
    url = "https://github.com/Readarr/Readarr/releases/download/v${version}/Readarr.develop.${version}.${os}-core-${arch}.tar.gz";
    hash = hash;
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/{bin,share/${pname}-${version}}
    cp -r * $out/share/${pname}-${version}/.
    makeWrapper "${dotnetCorePackages.runtime_3_1}/bin/dotnet" $out/bin/Readarr \
      --add-flags "$out/share/${pname}-${version}/Readarr.dll" \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [
        mono icu sqlite openssl ]}
    runHook postInstall
  '';

  meta = {
    description = "Ebook collection manager for Usenet and BitTorrent users";
    homepage = "https://readarr.com/";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ tboerger ];
    platforms = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
  };
}
