{
  stdenv,
  lib,
  buildPythonApplication,
  fetchFromGitHub,
  replaceVars,
  setuptools,
  inquirerpy,
  requests,
  tqdm,
  lzip,
  util-linux,
  nix-update-script,
}:
let
  pname = "waydroid-script";
  version = "0-unstable-2026-09-11";
  src = fetchFromGitHub {
    repo = "waydroid_script";
    owner = "casualsnek";
    rev = "48dbfaf34a6ddbe78688c530f9ba1c26522aafb2";
    hash = "sha256-UBbnYhiRCf4sMwpEDMlpJuTEsN66B2hZ8BPz6cCGXAc=";
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
in
buildPythonApplication rec {
  inherit pname version src;
  pyproject = true;

  build-system = [ setuptools ];

  dependencies = [
    inquirerpy
    lzip
    requests
    tqdm
    util-linux
  ];

  postPatch =
    let
      setup = replaceVars ./setup.py {
        inherit pname;
        desc = meta.description;
        version = builtins.replaceStrings [ "-" ] [ "." ] (lib.strings.removePrefix "0-unstable-" version);
      };
    in
    ''
      ln -s ${setup} setup.py

      substituteInPlace stuff/general.py \
        --replace-fail "os.path.dirname(__file__), \"..\", \"bin\"," "\"${resetprop}/share\","
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
    mainProgram = "waydroid-script";
  };
}
