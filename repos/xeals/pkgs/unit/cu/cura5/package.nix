{ stdenv
, fetchurl
, writeScriptBin
, appimageTools
}:

let
  pname = "cura5";
  version = "5.4.0";
  name = "${pname}-${version}";

  cura5 = appimageTools.wrapType2 {
    inherit pname version;
    src = fetchurl {
      url = "https://github.com/Ultimaker/Cura/releases/download/${version}/Ultimaker-Cura-${version}-linux-modern.AppImage";
      hash = "sha256-QVv7Wkfo082PH6n6rpsB79st2xK2+Np9ivBg/PYZd74=";
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
    exec "${cura5}/bin/${name}" "''${args[@]}"
  '';
in
script // {
  inherit name pname version;
  meta.platforms = [ "x86_64-linux" ];
}
