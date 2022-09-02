{ lib, stdenv, fetchFromGitHub, python3Packages }:

python3Packages.buildPythonApplication rec {
  pname = "huami-token";
  version = "2021-10-30";

  src = fetchFromGitHub {
    owner = "argrento";
    repo = "huami-token";
    rev = "c88162682dd16671ea22ea0e8e6f913494b3bd78";
    hash = "sha256-LMVFlpMueQV8jfX2A968AYftIT2pAe+FTOS7X21ml8w=";
  };

  dontUseSetuptoolsBuild = true;
  dontUseSetuptoolsCheck = true;

  installPhase =
    let
      pythonEnv = python3Packages.python.withPackages (p: with p; [
        requests
        rich
      ]);
    in
    ''
      site_packages=$out/lib/${python3Packages.python.libPrefix}/site-packages
      mkdir -p $site_packages
      cp *.py $site_packages

      makeWrapper ${pythonEnv.interpreter} $out/bin/huami_token \
        --add-flags "$site_packages/huami_token.py"
    '';

  meta = with lib; {
    description = "Script to obtain watch or band bluetooth token from Huami servers";
    inherit (src.meta) homepage;
    license = licenses.free;
    maintainers = with maintainers; [ sikmir ];
  };
}
