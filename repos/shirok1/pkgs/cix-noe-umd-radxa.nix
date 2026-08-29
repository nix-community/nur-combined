{
  stdenv,
  lib,
  fetchurl,
  cix-npu-umd,
  dpkg,
  autoPatchelfHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "cix-noe-umd-radxa";
  version = "3.1.2";

  src = fetchurl {
    url = "https://github.com/radxa-pkg/cix-prebuilt/releases/download/26Q2-2607/cix-noe-umd_${finalAttrs.version}_arm64.deb";
    hash = "sha256-LHN9BTedqgYjuNZp96siRVoxGYTwX3jS66P1tlbcCts=";
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
    if [[ -L usr/share/cix/lib/libnoe.so || -L usr/share/cix/lib/libnoe.so.3 ]]; then
      echo "Radxa fixed the libnoe symlinks; remove the packaging workaround" >&2
      exit 1
    fi
    ln -sf libnoe.so.3.1.0 $out/lib/libnoe.so.3
    ln -sf libnoe.so.3 $out/lib/libnoe.so
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
    description = "Radxa CIX NOE userspace library";
    homepage = "https://github.com/radxa-pkg/cix-prebuilt";
    license = lib.licenses.unfreeRedistributable;
    platforms = [ "aarch64-linux" ];
  };
})
