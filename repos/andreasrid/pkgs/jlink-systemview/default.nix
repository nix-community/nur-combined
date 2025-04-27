{
  lib,
  buildFHSEnv,
  fetchzip,
  requireFile,
  stdenvNoCC,
  extraPkgs ? [ ],
}:

let
  package = stdenvNoCC.mkDerivation rec {
    pname = "jlink-systemview";
    version = "360d";

    src = requireFile {
      name = "SystemView_Linux_V360d_x86_64.tgz";
      url = "https://www.segger.com/downloads/systemview/SystemView_Linux_V360d_x86_64.tgz";
      sha256 = "0npqicnwkdwppiiqbnmy1anhq9p294abzyw5sbafxlyrx461vasf";
    };

    installPhase = ''
      mkdir -p $out/{bin,opt/SEGGER/SystemView}

      # Bulk copy everything
      cp --preserve=mode -r SystemView Description Doc Sample lib* "$out/opt/SEGGER/SystemView"

      # Create links where needed
      ln -s /opt/SEGGER/SystemView/SystemView $out/bin
    '';

    meta = with lib; {
      description = "SystemView - Real-time Analysis and Visualization";
      longDescription = ''
        SEGGER SystemView Recording and analyzing runtime behavior of embedded systems
      '';
      homepage = "https://segger.com";
      sourceProvenance = with sourceTypes; [ binaryBytecode ];
      platforms = [ "x86_64-linux" ];
    };
  };
in
buildFHSEnv {
  inherit (package) pname version meta;
  runScript = "SystemView";
  targetPkgs =
    pkgs:
    (with pkgs; [
      package
      freetype
      fontconfig
    ])
    ++ (with pkgs.xorg; [
      libSM
      libICE
      libXrender
      libXrandr
      libXfixes
      libXcursor
      libX11
    ])
    ++ extraPkgs;
}
