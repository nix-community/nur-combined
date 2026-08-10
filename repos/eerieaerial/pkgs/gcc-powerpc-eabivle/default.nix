{
  lib,
  stdenv,
  requireFile,
  unzip,
}:

stdenv.mkDerivation rec {
  pname = "gcc-powerpc-eabivle";
  version = "4.9.4";

  src = requireFile {
  name = "gcc-4.9.4-Ee200-eabivle-x86_64-linux-g2724867.zip";
  message = ''
    This file cannot be downloaded automatically.
    Please download "NXP Embedded GCC for Power Architecture, v4.9.4 build 1705 - Linux"
    from NXP's website:
    https://www.nxp.com/design/design-center/software/automotive-software-and-tools/s32-design-studio-ide/s32-design-studio-for-power-architecture:S32DS-PA
    and add it to the Nix store using:
        nix-store --add-fixed sha256 gcc-4.9.4-Ee200-eabivle-x86_64-linux-g2724867.zip
    '';
  sha256 = "f2c597079634bd69713511f02732035f6db61777d432d4921fab3403fc874d1b";
  };

  setSourceRoot = "sourceRoot=`pwd`";

  nativeBuildInputs = [ unzip ];

  dontConfigure = true;
  dontBuild = true;
  dontPatchELF = true;
  dontStrip = true;
  dontFixup = true;

  installPhase = ''
    shopt -s extglob
    mkdir -p $out
    cp -r powerpc-eabivle-4_9/!(patches_applied|releasenotes.pdf) $out
  '';

  meta = with lib; {
    description = "Pre-built GNU toolchain for NXP PowerPC processors";
    homepage = "https://www.nxp.com/design/design-center/software/automotive-software-and-tools/s32-design-studio-ide/s32-design-studio-for-power-architecture:S32DS-PA";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    maintainers = with maintainers; [ eerieaerial ];
  };
}
