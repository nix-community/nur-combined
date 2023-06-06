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
  version = "unstable-2023-05-28";

  src = fetchFromGitHub {
    repo = "waydroid_script";
    owner = "casualsnek";
    rev = "59547e774335c12f08d20b65490bb1be840d7f87";
    hash = "sha256-8Y/ydjJT07qxASkybDk4du1GnUDoJhoAZ9KfE+K+9zA=";
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
