{ lib
, stdenv
, fetchFromGitHub
, fetchgit
, symlinkJoin
, buildNpmPackage
, python3
}:

let
  pname = "lfreader";
  version = "1.0.2";
  src = fetchFromGitHub {
    owner = "DCsunset";
    repo = "LFReader";
    rev = "v${version}";
    hash = "sha256-2+/vGgt3Gm+XLnRsXfapNOXUKMD2NEfRmpNsxKedFkE=";
  };

  frontendDrv = buildNpmPackage {
    inherit pname version src;
    sourceRoot = "${src.name}/frontend";

    npmDepsHash = "sha256-UwRYI/CGD5qLqxtK29ZYTtUHL00sldFhBWJ4McJXkfw=";

    installPhase = ''
      runHook preInstall

      mkdir -p $out/share
      mv dist $out/share/${pname}

      runHook postInstall
    '';
  };

  backendDrv = python3.pkgs.buildPythonApplication {
    inherit pname version src;
    sourceRoot = "${src.name}/backend";

    pyproject = true;

    nativeBuildInputs = with python3.pkgs; [
      setuptools
    ];
    propagatedBuildInputs = with python3.pkgs; [
      aiohttp
      beautifulsoup4
      feedparser
      fastapi
      uvicorn
    ];
  };
in
symlinkJoin {
  name = "${pname}-${version}";
  paths = [ frontendDrv backendDrv ];
  meta = with lib; {
    description = "A self-hosted Local-first Feed Reader written in Python and Preact/React.";
    homepage = "https://github.com/DCsunset/LFReader";
    license = licenses.agpl3;
  };
}

