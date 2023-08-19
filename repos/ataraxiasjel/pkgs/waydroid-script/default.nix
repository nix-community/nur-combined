{ lib
, python3Packages
, fetchFromGitHub
, substituteAll
, lzip
, sqlite
, util-linux
, nix-update-script
# inquirerpy
, callPackage
}: let
  pfzy = callPackage ./pfzy.nix { };
  inquirerpy = callPackage ./inquirerpy.nix { inherit pfzy; };
in python3Packages.buildPythonApplication rec {
  pname = "waydroid-script";
  version = "unstable-2023-08-18";

  src = fetchFromGitHub {
    repo = "waydroid_script";
    owner = "casualsnek";
    rev = "4db9bb3cba248212cef043786f47149609e79a71";
    hash = "sha256-oUQ7t/pR1900kWd/pn16YYWp0MpW4NpRP8+/3FXoG5k=";
  };

  propagatedBuildInputs = with python3Packages; [
    inquirerpy
    lzip
    requests
    sqlite
    tqdm
    util-linux
  ];

  postPatch =
    let
      setup = substituteAll {
        src = ./setup.py;
        inherit pname;
        desc = meta.description;
        version = builtins.replaceStrings [ "-" ] [ "." ]
          (lib.strings.removePrefix "unstable-" version);
      };
    in
    ''
      ln -s ${setup} setup.py
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
