{ stdenv
, lib
, python3Packages
, fetchFromGitHub
, substituteAll
, lzip
, util-linux
, nix-update-script
}:
let
  pname = "waydroid-script";
  version = "unstable-2024-01-09";
  src = fetchFromGitHub {
    repo = "waydroid_script";
    owner = "casualsnek";
    rev = "b12c06568c46ce521fc89fdf1d6c26f42398e06b";
    hash = "sha256-+DbkqVeRBs/ADybqwi26BnRVsSExHG35wEAiDP5urJ4=";
  };

  resetprop = stdenv.mkDerivation {
    pname = "resetprop";
    inherit version src;
    dontBuild = true;
    installPhase = ''
      mkdir -p $out/share
      cp -r bin/* $out/share/
    '';
  };
in python3Packages.buildPythonApplication rec {
  inherit pname version src;

  propagatedBuildInputs = with python3Packages; [
    inquirerpy
    requests
    tqdm

    lzip
    util-linux
  ];

  postPatch = let
    setup = substituteAll {
      src = ./setup.py;
      inherit pname;
      desc = meta.description;
      version = builtins.replaceStrings [ "-" ] [ "." ]
        (lib.strings.removePrefix "unstable-" version);
    };
  in ''
    ln -s ${setup} setup.py

    substituteInPlace stuff/general.py \
      --replace "os.path.dirname(__file__), \"..\", \"bin\"," "\"${resetprop}/share\","
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--version=branch" ];
  };

  meta = with lib; {
    description = "Python Script to add libraries to waydroid";
    homepage = "https://github.com/casualsnek/waydroid_script";
    license = licenses.gpl3;
    platforms = platforms.linux;
    maintainers = with maintainers; [ ataraxiasjel ];
  };
}
