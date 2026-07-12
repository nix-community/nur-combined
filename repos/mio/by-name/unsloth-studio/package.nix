{
  lib,
  stdenv,
  fetchFromGitHub,
  python3,
  fetchNpmDeps,
  npmHooks,
  nodejs_22,
}:

let
  pname = "unsloth";
  version = "0.1.481-beta";

  src = fetchFromGitHub {
    owner = "unslothai";
    repo = "unsloth";
    rev = "v0.1.481-beta";
    hash = "sha256-K0tdUqnpCpUG2hsEc+NpIcYNP+iD8/1yoFkdPYTWGFg=";
  };

  # Unsloth Studio frontend is built with npm/vite
  frontend = stdenv.mkDerivation {
    pname = "${pname}-studio-frontend";
    inherit version src;

    sourceRoot = "${src.name}/studio/frontend";

    npmDeps = fetchNpmDeps {
      src = "${src}/studio/frontend";
      hash = "sha256-CopfqJd8q14y5vRxkrezg1a11ZJ263OWMoMIfG086ME=";
    };

    nativeBuildInputs = [
      nodejs_22
      npmHooks.npmConfigHook
    ];

    buildPhase = ''
      runHook preBuild
      npm run build
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      cp -r dist $out
      runHook postInstall
    '';
  };

in
python3.pkgs.buildPythonApplication {
  inherit pname version src;
  pyproject = true;

  nativeBuildInputs = with python3.pkgs; [
    setuptools
    setuptools-scm
  ];

  propagatedBuildInputs = with python3.pkgs; [
    typer
    rich
    pydantic
    pyyaml
    nest-asyncio
    psutil
    numpy
    protobuf
  ];

  # Copy the prebuilt frontend into the python package source before building
  preBuild = ''
    rm -rf studio/frontend/dist
    cp -r ${frontend} studio/frontend/dist
    chmod -R u+w studio/frontend/dist
  '';

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail 'setuptools==80.9.0' 'setuptools' \
      --replace-fail 'setuptools-scm==9.2.0' 'setuptools-scm'
  '';

  meta = {
    description = "2-5X faster training, reinforcement learning & finetuning with Unsloth Studio UI";
    homepage = "https://unsloth.ai/docs/new/studio";
    license = lib.licenses.asl20;
    maintainers = [ ];
    mainProgram = "unsloth";
  };
}
