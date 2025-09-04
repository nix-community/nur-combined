{
  lib,
  stdenv,
  requireFile,
  unzip,
}:

stdenv.mkDerivation rec {
  pname = "gcc-tricore-embedded";
  version = "05-2025";

  src = requireFile {
  name = "aurixgcc_05-2025_Linux_x86-x64.zip";
  message = ''
    This file cannot be downloaded automatically.
    Please download aurixgcc_05-2025_Linux_x86-x64.zip from Infineon's website:
    https://softwaretools.infineon.com/assets/com.ifx.tb.tool.aurixgcc/
    and add it to the Nix store using:
        nix-store --add-fixed sha256 aurixgcc_05-2025_Linux_x86-x64.zip
    '';
  sha256 = "61779b50f51a37fb59549936557e4a01e652d34bc66057123a6ec1a89face654";
  };

  setSourceRoot = "sourceRoot=`pwd`";

  nativeBuildInputs = [ unzip ];

  dontConfigure = true;
  dontBuild = true;
  dontPatchELF = true;
  dontStrip = true;
  dontFixup = true;

  installPhase = ''
    mkdir -p $out
    cp -r * $out

    chmod +x $out/bin/*
    chmod +x $out/tricore-elf/bin/*
    chmod +x $out/mcs-elf/bin/*
    chmod +x $out/libexec/gcc/tricore-elf/11.3.1/*
    chmod +x $out/libexec/gcc/tricore-elf/11.3.1/install-tools/*
  '';

  meta = with lib; {
    description = "Pre-built GNU toolchain for Infineon AURIX TriCore processors";
    homepage = "https://softwaretools.infineon.com/assets/com.ifx.tb.tool.aurixgcc/";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    maintainers = with maintainers; [ eerieaerial ];
  };
}
