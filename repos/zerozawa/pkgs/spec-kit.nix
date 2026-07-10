{
  lib,
  python3Packages,
  fetchFromGitHub,
}:

python3Packages.buildPythonApplication rec {
  pname = "spec-kit";
  version = "0.12.10";

  pyproject = true;

  src = fetchFromGitHub {
    owner = "github";
    repo = "spec-kit";
    rev = "v${version}";
    hash = "sha256-L26j+ZBom51gdX3NCYrjVBk9kKhpm68bc0OMzyXRM0I=";
  };

  build-system = with python3Packages; [
    hatchling
  ];

  propagatedBuildInputs = with python3Packages; [
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

  pythonImportsCheck = [ "specify_cli" ];

  doCheck = false;

  meta = with lib; {
    description = "Specify CLI — toolkit for Spec-Driven Development (SDD) from GitHub";
    longDescription = ''
      Spec Kit is GitHub's official toolkit for Spec-Driven Development.
      It flips the traditional script: specifications become executable,
      directly generating working implementations rather than just guiding them.

      The `specify` CLI helps bootstrap projects, manage spec artifacts,
      and integrates with AI coding assistants via slash commands.
    '';
    homepage = "https://github.com/github/spec-kit";
    license = licenses.mit;
    platforms = platforms.linux;
    sourceProvenance = with sourceTypes; [ fromSource ];
    mainProgram = "specify";
    maintainers = [ ];
  };
}
