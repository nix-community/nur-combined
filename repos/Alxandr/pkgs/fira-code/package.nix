{
  lib,
  pkgs,
  fetchFromGitHub,
  useVariableFont ? true,
  nix-update-script,
}:

let
  src = fetchFromGitHub {
    owner = "tonsky";
    repo = "FiraCode";
    rev = "ecd367b040ad92a28b64fa93135775f7e2417b37";
    sha256 = "sha256-jjV+63PCxCxzMjur2x/MVOfNUMJEFnG+8Zl6NSri1VA=";
  };

  updateScript = nix-update-script {
    extraArgs = [
      "--version"
      "branch"
      "--override-filename"
      "pkgs/fira-code/package.nix"
    ];
  };

  # https://github.com/NixOS/nixpkgs/issues/570271
  # Override the interpreter so gftools' python.withPackages environments also
  # use the workaround. Overriding only the package scope leaves those unchanged.
  python312 = pkgs.python312.override {
    self = python312;
    packageOverrides = lib.composeExtensions (pkgs.python312.packageOverrides or (_: _: { })) (
      _: prev: {
        anyio = prev.anyio.overridePythonAttrs (old: {
          disabledTests =
            (old.disabledTests or [ ])
            ++ lib.optionals (lib.versionAtLeast pkgs.python312.version "3.12.15") [
              "test_tls_connectable"
              # This 100 ms deadline expires under CI load.
              "test_deadline_moved"
            ];
        });
      }
    );
  };
  python312Packages = python312.pkgs;

  meta = {
    description = "Monospaced font with programming ligatures";
    homepage = "https://github.com/tonsky/FiraCode";
    license = lib.licenses.ofl;
  };

in
if useVariableFont then
  pkgs.callPackage ./vf.nix {
    inherit meta src updateScript;
    inherit (python312Packages) fontmake gftools;
  }
else
  pkgs.callPackage ./ttf.nix {
    inherit meta src updateScript;
    inherit (python312Packages) fontmake;
  }
