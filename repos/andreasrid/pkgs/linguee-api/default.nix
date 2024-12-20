{
  python3Packages,
  fetchFromGitHub,
  python-xextract,
  writeShellScript,
}:

with python3Packages;

let
  # fastapi and linguee-api depend on different version of pydantic
  # replace dependency pydantic with pydantic_1
  fastapi-customized = python3Packages.fastapi.override{ pydantic = pydantic_1; };

  linguee-api = buildPythonPackage {
    pname = "linguee-api";
    version = "2.6.3";
    pyproject = true;
    doCheck = false;
    src = fetchFromGitHub {
      owner = "imankulov";
      repo = "linguee-api";
      rev = "9844c8247b07a2771b1555f09c8bbc6ea83f08d7";
      hash = "sha256-CSskCYnB+mD+jxXWtAuXhLal9UWWFcEPR2olN7EfEZU=";
    };

    nativeBuildInputs = with pkgs; [
      poetry-core
      pythonRelaxDepsHook
      makeWrapper
    ];

    pythonRelaxDeps = true;

    propagatedBuildInputs = with python3Packages; [
      aiosqlite
      async-lru
      fastapi-customized
      httpx
      loguru
      lxml
      pydantic_1
      python-dotenv
      sentry-sdk
      uvicorn
      python-xextract
    ];

    meta = with lib; {
      description = "Proxy to convert HTML responses from linguee.com to JSON format";
      homepage = "https://github.com/imankulov/linguee-api";
      license = licenses.mit;
      maintainers = [ "Andreas Rid" ];
    };
  };

in pkgs.writeShellApplication {
    name = "linguee-api-script";
    runtimeInputs = [ (pkgs.python3.withPackages (p: [ p.uvicorn linguee-api ])) ];
    text = ''
      uvicorn "$@" linguee_api.api:app
    '';
}
