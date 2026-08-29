{
  stdenv,
  lib,
  requireFile,
  dpkg,
  autoPatchelfHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "cix-npu-umd";
  version = "3.2.0-cixdeb13-260714";

  src = requireFile {
    name = "cix-npu-umd_${finalAttrs.version}_arm64.deb";
    hash = "sha256-+FHLmZb4Qi1yPagqgagRt9qPUa8nrwMm9poKtl6bSRo=";
    message = "Add the CIX NPU UMD package to the Nix store with: nix-store --add-fixed sha256 cix-npu-umd_${finalAttrs.version}_arm64.deb";
  };

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
  ];

  buildInputs = [ stdenv.cc.cc.lib ];

  unpackPhase = ''
    runHook preUnpack
    dpkg-deb -x $src .
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/pkgconfig $out/include
    cp -a usr/share/cix/lib/. $out/lib/
    cp -a usr/share/cix/include/. $out/include/
    substitute usr/lib/aarch64-linux-gnu/pkgconfig/cix-npu-umd.pc \
      $out/lib/pkgconfig/cix-npu-umd.pc \
      --replace-fail 'prefix=/usr' "prefix=$out" \
      --replace-fail 'libdir=''${prefix}/share/cix/lib' 'libdir=''${prefix}/lib' \
      --replace-fail 'includedir=''${prefix}/share/cix/include' 'includedir=''${prefix}/include'

    runHook postInstall
  '';

  meta = {
    description = "CIX NPU userspace driver";
    license = lib.licenses.unfreeRedistributable;
    platforms = [ "aarch64-linux" ];
  };
})
