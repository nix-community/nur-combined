{
  lib,
  nix-update,
  python3Packages,
}:

let
  inherit (lib.importTOML ../pyproject.toml) project;
in
python3Packages.buildPythonApplication (finalAttrs: {
  __structuredAttrs = true;
  strictDeps = true;

  pname = project.name;
  inherit (project) version;
  pyproject = true;

  src = lib.fileset.toSource {
    root = ../.;
    fileset = lib.fileset.unions [
      ../pyproject.toml
      (lib.fileset.fileFilter (file: file.hasExt "py") ../updaters)
      (lib.fileset.fileFilter (file: file.hasExt "py") ../tests)
    ];
  };

  build-system = [ python3Packages.setuptools ];
  makeWrapperArgs = [
    "--prefix"
    "PATH"
    ":"
    (lib.makeBinPath [ nix-update ])
  ];

  doCheck = true;
  checkPhase = ''
    runHook preCheck
    python -m unittest discover -s tests
    runHook postCheck
  '';
  pythonImportsCheck = [ "updaters" ];

  meta = {
    description = "Select GitHub release versions for nix-update";
    mainProgram = finalAttrs.pname;
  };
})
