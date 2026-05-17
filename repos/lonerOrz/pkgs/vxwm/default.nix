{
  lib,
  stdenv,
  fetchFromCodeberg,
  libx11,
  libxinerama,
  libxft,
  fontconfig,
  freetype,
  writeText,
  pkg-config,

  # customization
  config,
  conf ? config.vxwm.conf or null,
  patches ? config.vxwm.patches or [ ],
  extraLibs ? config.vxwm.extraLibs or [ ],
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "vxwm";
  version = "0-unstable-2026-05-16";

  src = fetchFromCodeberg {
    owner = "wh1tepearl";
    repo = "vxwm";
    rev = "c0ad915d0a91a28c95b4d7112b146a515efb6db0";
    hash = "sha256-KdN51NOZe1wjg2oZXW19TM4PxseyUqwLo2OamMY5C0Q=";
  };

  nativeBuildInputs = lib.optional stdenv.hostPlatform.isStatic pkg-config;

  buildInputs = [
    libx11
    libxinerama
    libxft
    fontconfig
    freetype
  ]
  ++ extraLibs;

  preBuild = ''
    makeFlagsArray+=(
      "PREFIX=$out"
      "CC=$CC"
      ${lib.optionalString stdenv.hostPlatform.isStatic ''
        LDFLAGS="$(${stdenv.cc.targetPrefix}pkg-config --static --libs x11 xinerama xft fontconfig)"
      ''}
    )
  '';

  inherit patches;

  postPatch =
    let
      configFile =
        if lib.isDerivation conf || builtins.isPath conf then conf else writeText "config.def.h" conf;
    in
    ''
      substituteInPlace config.mk \
        --replace-fail 'PREFIX = /usr/local' "PREFIX = $out" \
        --replace-fail '/usr/X11R6/include' "${libx11.dev}/include" \
        --replace-fail '/usr/X11R6/lib' "${libx11.out}/lib" \
        --replace-fail '/usr/include/freetype2' "${freetype.dev}/include/freetype2"

      # fix rvx path
      substituteInPlace rvx \
        --replace-fail 'killall vxwm' 'pkill -x vxwm || true' \
        --replace-fail 'dbus-run-session vxwm' "dbus-run-session $out/bin/vxwm"

      sed -i -E "s|^[[:space:]]*vxwm |$out/bin/vxwm |" rvx

      sed -i '/{ ClkWinTitle.*zoom/d' config.def.h

      # custom config
      ${lib.optionalString (conf != null) ''
        cp ${configFile} config.def.h
      ''}
    '';

  enableParallelBuilding = true;

  passthru.updateArgs = [ "--version=branch" ];

  meta = with lib; {
    description = "Versatile X Window Manager — dwm fork with infinite tags and modular features";
    homepage = "https://codeberg.org/wh1tepearl/vxwm";
    mainProgram = "vxwm";
    license = licenses.mit;
    platforms = platforms.linux;
    maintainers = with maintainers; [ lonerOrz ];
  };
})
