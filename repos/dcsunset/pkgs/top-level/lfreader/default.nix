{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchPnpmDeps,
  pnpmConfigHook,
  pnpm,
  nodejs,
  python3,
  symlinkJoin,
}:

let
  name = "lfreader";
  version = "4.0.1";
  src = fetchFromGitHub {
    owner = "DCsunset";
    repo = "LFReader";
    rev = "v${version}";
    hash = "sha256-K+BLAD58DljPxQuJuTYp+v90tVVjYTyYL+j2/0xX6eI=";
  };

  # reference: https://nixos.org/manual/nixpkgs/unstable/#javascript-pnpm
  frontendDrv = stdenv.mkDerivation (finalAttrs: {
    pname = "${name}-frontend";
    inherit version src;
    sourceRoot = "${src.name}/frontend";

    nativeBuildInputs = [
      nodejs # in case scripts are run outside of a pnpm call
      pnpmConfigHook
      pnpm # At least required by pnpmConfigHook, if not other (custom) phases
    ];

    pnpmDeps = fetchPnpmDeps {
      inherit (finalAttrs) pname version src sourceRoot;
      fetcherVersion = 3;
      hash = "sha256-Aw0AFyuUUTDZiwM8cMf7LWqnB6Hhq8ISntxI2qPtA9g=";
    };

    buildPhase = ''
      runHook preBuild

      pnpm build

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out/share
      mv dist $out/share/${name}

      runHook postInstall
    '';
  });

  backendDrv = python3.pkgs.buildPythonApplication {
    pname = "${name}-backend";
    inherit version src;
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

