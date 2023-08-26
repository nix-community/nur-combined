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
  version = "unstable-2023-08-25";

  src = fetchFromGitHub {
    repo = "waydroid_script";
    owner = "casualsnek";
    rev = "77e222fb166c645a18c6a65aba8547631ff17704";
    hash = "sha256-FstkA6SKqrX0bD4NfyFbPQCLyfHfvWakmiRPmTGo78g=";
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
