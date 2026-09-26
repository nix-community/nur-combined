{
  lib,
  python3Packages,
  fetchFromGitHub,
  makeWrapper,
  git,
}:

python3Packages.buildPythonApplication rec {
  pname = "spec-kit";
  version = "1.0.11";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "github";
    repo = "spec-kit";
    rev = "v${version}";
    hash = "sha256-qjzT6BoPjKovAya7UnZ4okc3NQEJQjmkwkD9/iXA+qs=";
  };

  build-system = [ python3Packages.hatchling ];

  dependencies = with python3Packages; [
    typer
    click
    rich
    platformdirs
    readchar
    pyyaml
    packaging
    pathspec
    json5
  ];

  nativeBuildInputs = [ makeWrapper ];

  postFixup = ''
    wrapProgram $out/bin/specify --prefix PATH : ${lib.makeBinPath [ git ]}
  '';

  doCheck = false;

  pythonImportsCheck = [ "specify_cli" ];

  meta = {
    description = "Toolkit to bootstrap projects for Spec-Driven Development (SDD)";
    homepage = "https://github.com/github/spec-kit";
    license = lib.licenses.mit;
    mainProgram = "specify";
  };
}
