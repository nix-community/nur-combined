{
  stdenv,
  lib,
  requireFile,
  cix-npu-umd,
  dpkg,
  autoPatchelfHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "cix-noe-umd";
  version = "3.1.4-cixdeb13-260714";

  src = requireFile {
    name = "cix-noe-umd_${finalAttrs.version}_arm64.deb";
    hash = "sha256-tgddxjMxhJRSto11XylAMyoIUfeUB3CBO+JIDA1Rq/g=";
    message = "Add the CIX NOE UMD package to the Nix store with: nix-store --add-fixed sha256 cix-noe-umd_${finalAttrs.version}_arm64.deb";
  };

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
  ];

  buildInputs = [
    cix-npu-umd
    stdenv.cc.cc.lib
  ];

  appendRunpaths = [ "${cix-npu-umd}/lib" ];

  unpackPhase = ''
    runHook preUnpack
    dpkg-deb -x $src .
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/pkgconfig $out/include $out/share
    cp -a usr/share/cix/lib/. $out/lib/
    cp -a usr/share/cix/include/. $out/include/
    cp -a usr/share/cix/pypi/. $out/share/
    substitute usr/lib/aarch64-linux-gnu/pkgconfig/cix-noe-umd.pc \
      $out/lib/pkgconfig/cix-noe-umd.pc \
      --replace-fail 'prefix=/usr' "prefix=$out" \
      --replace-fail 'libdir=''${prefix}/share/cix/lib' 'libdir=''${prefix}/lib' \
      --replace-fail 'includedir=''${prefix}/share/cix/include' 'includedir=''${prefix}/include'

    runHook postInstall
  '';

  meta = {
    description = "CIX NOE userspace library";
    license = lib.licenses.unfreeRedistributable;
    platforms = [ "aarch64-linux" ];
  };
})
