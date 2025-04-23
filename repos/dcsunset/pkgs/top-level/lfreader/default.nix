{ lib
, fetchFromGitHub
, symlinkJoin
, buildNpmPackage
, python3
, pkg-config
, vips
}:

let
  pname = "lfreader";
  version = "3.4.0";
  name = "${pname}-${version}";
  src = fetchFromGitHub {
    owner = "DCsunset";
    repo = "LFReader";
    rev = "v${version}";
    hash = "sha256-gbywTjnNbqT9UoMrLg25FpZkW75P8mVmTl+TXjnjQl0=";
  };

  frontendDrv = buildNpmPackage {
    inherit pname version src;
    name = "${name}-frontend";
    sourceRoot = "${src.name}/frontend";

    npmDepsHash = "sha256-U6FqoArH8jrNoQdySTw6CLJlaGbUtOXAw+MEbxvdi14=";

    # Required for sharp dependency (used by pwa-assets-generator)
    nativeBuildInputs = [
      pkg-config
      vips
    ];

    buildInputs = [
      vips
    ];

    installPhase = ''
      runHook preInstall

      mkdir -p $out/share
      mv dist $out/share/${pname}

      runHook postInstall
    '';
  };

  backendDrv = python3.pkgs.buildPythonApplication {
    inherit pname version src;
    name = "${name}-backend";
    sourceRoot = "${src.name}/backend";

    pyproject = true;

    nativeBuildInputs = with python3.pkgs; [
      setuptools
    ];
    propagatedBuildInputs = with python3.pkgs; [
      aiohttp
      beautifulsoup4
      pydantic
      feedparser
      fastapi
      uvicorn
    ];
  };
in
symlinkJoin {
  inherit name;
  paths = [ frontendDrv backendDrv ];
  meta = with lib; {
    description = "A self-hosted Local-first Feed Reader written in Python and Preact/React.";
    homepage = "https://github.com/DCsunset/LFReader";
    license = licenses.agpl3Only;
  };
}

