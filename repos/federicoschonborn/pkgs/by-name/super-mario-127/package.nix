{
  lib,
  buildFHSEnv,
  requireFile,
  runCommand,
  unzip,
}:

let
  version = "0.8.0";
  zipFile = requireFile {
    name = "SuperMario127v${version}Linux.zip";
    url = "https://charpurrr.itch.io/super-mario-127";
    hash = "sha256-l713xdEvwnOV8OMyDQ4/qU7VMj/uDViAJR5gl+R/vCU=";
  };
  zipContent = runCommand "content" { } ''
    ${lib.getExe unzip} ${zipFile} -d $out
    chmod +x $out/Super_Mario_127v${version}.x86_64
  '';
in

buildFHSEnv {
  pname = "super-mario-127";
  inherit version;

  targetPkgs =
    pkgs: with pkgs; [
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
    ];

  runScript = "${zipContent}/Super_Mario_127v${version}.x86_64 --verbose";

  meta = {
    mainProgram = "super-mario-127";
    description = "Fan sequel to Super Mario 63";
    homepage = "https://charpurrr.itch.io/super-mario-127";
    license = lib.licenses.unfree;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
}
