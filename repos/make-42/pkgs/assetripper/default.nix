{
  stdenv,
  lib,
  fetchzip,
  autoPatchelfHook,
  pkgs,
}:
stdenv.mkDerivation rec {
  pname = "assetripper";
  version = "1.1.11";

  src = fetchzip {
    url = "https://github.com/AssetRipper/AssetRipper/releases/download/${version}/AssetRipper_linux_x64.zip";
    hash = "sha256-AylkhB2jim7lrRAER4x+cv7BqCcpuRmUiPlG25A/wEc=";
    stripRoot = false;
  };

  nativeBuildInputs = with pkgs; [
    autoPatchelfHook
    unzip
    openssl.dev
    openssl.out
  ];

  buildInputs = with pkgs; [
    dbus.lib
    libgcc.lib
    openssl.dev
    openssl.out
  ];

  sourceRoot = ".";

  preFixup = let
    # we prepare our library path in the let clause to avoid it become part of the input of mkDerivation
    libPath = with pkgs;
      lib.makeLibraryPath [
        openssl
      ];
  in ''
    patchelf \
      --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
      --set-rpath "${libPath}" \
      $out/bin/assetripper
  '';

  installPhase = ''
    runHook preInstall
    install -m755 -D $src/AssetRipper.GUI.Free $out/bin/assetripper
    install -m755 -D $src/crunch.dll $out/bin/crunch.dll
    install -m755 -D $src/crunchunity.dll $out/bin/crunchunity.dll
    install -m755 -D $src/libcapstone.so $out/bin/libcapstone.so
    install -m755 -D $src/libnfd.so $out/bin/libnfd.so
    install -m755 -D $src/libTexture2DDecoderNative.so $out/bin/libTexture2DDecoderNative.so
    runHook postInstall
    runHook preFixup
  '';

  meta = with lib; {
    homepage = "https://github.com/AssetRipper/AssetRipper";
    description = "AssetRipper";
    platforms = platforms.linux;
  };
}
