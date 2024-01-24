{ buildNpmPackage
, fetchFromGitHub
, lib
, esbuild
, buildGoModule
, nodejs
, python3Packages
}:

let


  src = fetchFromGitHub {
    owner = "ollama-webui";
    repo = "ollama-webui";
    rev = "f079cb6b563145f664c746cc4a96cc782699c4f2";
    hash = "sha256-ePLh6hwmyVUH0px9NgaOIMn0lb+tmwq47CPSyiQBpdU=";
  };
  version = "unstable-2024-01-19";

  esbuild' = esbuild.override {
    buildGoModule = args: buildGoModule (args // rec {
      version = "0.18.20";
      src = fetchFromGitHub {
        owner = "evanw";
        repo = "esbuild";
        rev = "v${version}";
        hash = "sha256-mED3h+mY+4H465m02ewFK/BgA1i/PQ+ksUNxBlgpUoI=";
      };
      # vendorHash = "sha256-+BfxCyg0KkDQpHt/wycy/8CTG6YBA/VJvJFhhzUnSiQ=";
    });
  };

in buildNpmPackage {
  pname = "ollama-webui";
  inherit version src;
  format = "other";

  npmDepsHash = "sha256-izUifKUWEvAIXJI/QuULnfpkLTOa1jTK7JR4SlqvdhQ=";

  buildPhase = ''
    runHook preBuild
    npm run build
    runHook postBuild
  '';

  nativeBuildInputs = [
    python3Packages.wrapPython
  ];

  pythonPath = [
    python3Packages.fastapi
    python3Packages.requests
    python3Packages.peewee
  ];

  installPhase = ''
    runHook preInstall

    APP_DIR=$out/share/ollama-webui
    mkdir -p $APP_DIR $out/bin
    cp -r build $APP_DIR/www
    cp -r backend $APP_DIR/backend

    runHook postInstall
  '';

  preFixup = ''
    buildPythonPath "$pythonPath"

    makeWrapper ${lib.getExe python3Packages.uvicorn} $out/bin/ollama-webui \
      --prefix PYTHONPATH : "$program_PYTHONPATH" \
      --chdir $APP_DIR/backend \
      --add-flags main:app
  '';

  env = {
    ESBUILD_BINARY_PATH = "${esbuild'}/bin/esbuild";
  };
}
