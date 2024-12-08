{ lib
, stdenv
, fetchurl
, writeScriptBin
, appimageTools
, copyDesktopItems
, makeDesktopItem
}:

let
  pname = "cura5";
  version = "5.6.0";
  name = "${pname}-${version}";

  cura5 = appimageTools.wrapType2 {
    inherit pname version;
    src = fetchurl {
      url = "https://github.com/Ultimaker/Cura/releases/download/${version}/Ultimaker-Cura-${version}-linux-X64.AppImage";
      hash = "sha256-EHiWoNpLKHPzv6rZrtNgEr7y//iVcRYeV/TaCn8QpEA=";
    };
    extraPkgs = _: [ ];
  };
  script = writeScriptBin pname ''
    #!${stdenv.shell}
    # AppImage version of Cura loses current working directory and treats all paths relateive to $HOME.
    # So we convert each of the files passed as argument to an absolute path.
    # This fixes use cases like `cd /path/to/my/files; cura mymodel.stl anothermodel.stl`.

    args=()
    for a in "$@"; do
      if [ -e "$a" ]; then
        a="$(realpath "$a")"
      fi
      args+=("$a")
    done
    exec "${cura5}/bin/cura5" "''${args[@]}"
  '';
in
stdenv.mkDerivation rec {
  inherit pname version;
  dontUnpack = true;

  nativeBuildInputs = [ copyDesktopItems ];
  desktopItems = [
    # Based on upstream.
    # https://github.com/Ultimaker/Cura/blob/main/packaging/AppImage/cura.desktop.jinja
    (makeDesktopItem {
      name = "cura";
      desktopName = "UltiMaker Cura";
      genericName = "3D Printing Software";
      comment = meta.longDescription;
      exec = "cura5";
      icon = "cura-icon";
      terminal = false;
      type = "Application";
      mimeTypes = [
        "model/stl"
        "application/vnd.ms-3mfdocument"
        "application/prs.wavefront-obj"
        "image/bmp"
        "image/gif"
        "image/jpeg"
        "image/png"
        "text/x-gcode"
        "application/x-amf"
        "application/x-ply"
        "application/x-ctm"
        "model/vnd.collada+xml"
        "model/gltf-binary"
        "model/gltf+json"
        "model/vnd.collada+xml+zip"
      ];
      categories = [ "Graphics" ];
      keywords = [ "3D" "Printing" ];
    })
  ];

  # TODO: Extract cura-icon from AppImage source.
  installPhase = ''
    mkdir -p $out/bin
    cp ${script}/bin/cura5 $out/bin/cura5
    runHook postInstall
  '';

  meta = {
    description = "3D printing software";
    homepage = "https://github.com/ultimaker/cura";
    longDescription = ''
      Cura converts 3D models into paths for a 3D printer. It prepares your print for maximum accuracy, minimum printing time and good reliability with many extra features that make your print come out great.
    '';
    license = lib.licenses.lgpl3;
    platforms = [ "x86_64-linux" ];
  };
}
