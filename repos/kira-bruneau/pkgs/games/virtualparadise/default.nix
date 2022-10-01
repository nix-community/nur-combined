{ lib
, stdenv
, fetchurl

, autoPatchelfHook
, wrapQtAppsHook
, zstd

, at-spi2-atk
, bullet
, curl
, glew
, libuv
, libvorbis
, mpg123
, openal
, opusfile

, cups
, libXcursor
, libXrandr
, libXScrnSaver
, libXtst
, mesa
, nss
, pango

, buildFHSUserEnv
}:

let
  unwrapped = stdenv.mkDerivation (finalAttrs: {
    pname = "virtualparadise";
    version = "0.4.3";

    src = fetchurl {
      url = "https://static.virtualparadise.org/downloads/arch/virtualparadise-${finalAttrs.version}-1-x86_64.pkg.tar.zst";
      sha256 = "sha256-mTLbR1I6nP1LXe6750oUSl1hcI+0Yhop19tU7f0LLF8=";
    };

    nativeBuildInputs = [
      autoPatchelfHook
      wrapQtAppsHook
      zstd
    ];

    buildInputs = [
      at-spi2-atk
      bullet
      curl
      glew
      libuv
      libvorbis
      mpg123
      openal
      opusfile

      # Additional libcef dependencies (unlisted in .PKGINFO)
      cups
      libXcursor
      libXrandr
      libXScrnSaver
      libXtst
      mesa
      nss
      pango
    ];

    installPhase = ''
      runHook preInstall
      cp -R . "$out"

      rm "$out/bin/virtualparadise"
      makeQtWrapper \
        "$out/lib/virtualparadise/virtualparadise" \
        "$out/bin/virtualparadise" \
        --set QT_QPA_PLATFORM xcb

      mkdir "$out/lib/virtualparadise/swiftshader"
      mv "$out/lib/virtualparadise/libGLESv2.so" "$out/lib/virtualparadise/swiftshader/libGLESv2.so"
      mv "$out/lib/virtualparadise/libEGL.so" "$out/lib/virtualparadise/swiftshader/libEGL.so"
      runHook postInstall
    '';

    postFixup = ''
      patchelf \
        --add-needed libudev.so.1 \
        "$out/lib/virtualparadise/libcef.so"
    '';

    meta = with lib; {
      description = "An online virtual universe consisting of several 3D worlds";
      homepage = "https://www.virtualparadise.org";
      license = licenses.unfree;
      maintainers = with maintainers; [ kira-bruneau ];
      platforms = [ "x86_64-linux" ];
      broken = true; # requires bullet 2.89
    };
  });
in
buildFHSUserEnv {
  name = unwrapped.pname;
  inherit (unwrapped) meta;

  extraBuildCommands = ''
    chmod +w usr/lib usr/share
    ln -s ${unwrapped}/lib/virtualparadise usr/lib
    ln -s ${unwrapped}/share/pixmaps usr/share
    ln -s ${unwrapped}/share/virtualparadise usr/share
  '';

  extraInstallCommands = ''
    mkdir -p "$out/share"
    ln -s ${unwrapped}/share/applications "$out/share"
    ln -s ${unwrapped}/share/pixmaps "$out/share"
  '';

  runScript = "${unwrapped}/bin/virtualparadise";
}
