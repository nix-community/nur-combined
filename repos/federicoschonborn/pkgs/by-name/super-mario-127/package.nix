{
  lib,
  stdenvNoCC,
  requireFile,
  buildFHSEnv,
  unzip,
}:

let
  version = "0.8.0";

  super-mario-127 = stdenvNoCC.mkDerivation (finalAttrs: {
    pname = "super-mario-127";
    inherit version;

    src = requireFile {
      name = "SuperMario127v${finalAttrs.version}Linux.zip";
      url = "https://charpurrr.itch.io/super-mario-127";
      hash = "sha256-l713xdEvwnOV8OMyDQ4/qU7VMj/uDViAJR5gl+R/vCU=";
    };

    nativeBuildInputs = [ unzip ];

    dontUnpack = true;

    installPhase = ''
      mkdir -p $out/{bin,opt/super-mario-127}
      unzip $src -d $out/opt/super-mario-127
      chmod +x $out/opt/super-mario-127/Super_Mario_127v${finalAttrs.version}.x86_64
      ln -s $out/opt/super-mario-127/Super_Mario_127v${finalAttrs.version}.x86_64 $out/bin/super-mario-127
    '';
  });
in

buildFHSEnv {
  pname = "super-mario-127";
  inherit version;

  targetPkgs =
    pkgs:
    [ super-mario-127 ]
    ++ (with pkgs; [
      alsa-lib
      libGL
      pulseaudio
      udev
      xorg.libX11
      xorg.libXcursor
      xorg.libXext
      xorg.libXi
      xorg.libXinerama
      xorg.libXrandr
      xorg.libXrender
    ]);

  runScript = "super-mario-127";

  meta = {
    description = "Fan sequel to Super Mario 63";
    homepage = "https://charpurrr.itch.io/super-mario-127";
    license = lib.licenses.unfree;
    platforms = lib.platforms.unix;
    maintainers = [ lib.maintainers.federicoschonborn ];
  };
}
