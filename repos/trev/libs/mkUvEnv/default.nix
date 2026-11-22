# Builds a virtual environment at $out with the exact wheels in uv.lock, like
# mkUvPackage, but without building the project: only its dependencies, the
# dependency `groups` and the `extras` are installed. For development shells
# and checks that need the dependencies, e.g. type checkers in the sandbox.
#
# With `editableRoot`, the project is installed editable: a `.pth` file adds the
# root to sys.path, with environment variables expanded when Python starts
# (e.g. "$REPO_ROOT/src"), and the entry points in pyproject.toml are installed.
# The wheel is built by python.pkgs.mkPythonEditablePackage.
#
# Only uv.lock and pyproject.toml are inputs, so with a path as `src` the
# environment doesn't change with the other files. They can be passed as `lock`
# and `pyproject` instead of `src`.
{
  callPackage,
  lib,
  python3,
  stdenv,
}:

let
  uvHook = callPackage ../uvHook { };

  # a file of the source, only copying the file itself to the store if the
  # source is a path
  sourceFile =
    src: name:
    if src == null then
      throw "mkUvEnv: src is required to find ${name}"
    else if lib.isPath src then
      src + "/${name}"
    else
      "${src}/${name}";
in

lib.extendMkDerivation {
  constructDrv = stdenv.mkDerivation;

  excludeDrvArgNames = [
    "src"
    "lock"
    "pyproject"
    "python"
    "groups"
    "extras"
    "overrides"
    "editableRoot"
  ];

  extendDrvArgs =
    finalAttrs:
    {
      src ? null,
      # read during evaluation, IFD if `src` is a derivation
      lock ? sourceFile src "uv.lock",
      # read during evaluation with `editableRoot`
      pyproject ? sourceFile src "pyproject.toml",
      python ? python3,
      # dependency groups to install
      groups ? [ ],
      # optional dependencies to install
      extras ? [ ],
      # packages to use instead of the ones in uv.lock, by name
      overrides ? { },
      # where to find the project's modules, installed editable if set
      editableRoot ? null,
      nativeBuildInputs ? [ ],
      buildInputs ? [ ],
      passthru ? { },
      meta ? { },
      ...
    }@args:
    let
      parsedLock = lib.importTOML lock;

      project = uvHook.findProject parsedLock;
      projectName = project.name or (throw "mkUvEnv: the project isn't in the lock");

      uv = uvHook.drvAttrs {
        inherit (finalAttrs) pname;
        lock = parsedLock;
        inherit python overrides;
        exportFlags = uvHook.exportFlags { inherit groups extras; };
        inherit nativeBuildInputs buildInputs;
        env = args.env or { };
      };

      editable =
        let
          metadata = (lib.importTOML pyproject).project or { };
        in
        python.pkgs.mkPythonEditablePackage {
          pname = projectName;
          version = project.version or metadata.version or "0";
          root = editableRoot;
          scripts = metadata.scripts or { };
          gui-scripts = metadata.gui-scripts or { };
          entry-points = metadata.entry-points or { };
        };
    in
    uv.attrs
    // {
      pname = args.pname or "${projectName}-env";
      version = args.version or project.version or "0";

      uvOverrides = uv.attrs.uvOverrides ++ lib.optional (editableRoot != null) editable.dist;

      dontUnpack = true;
      dontBuild = true;
      # stripping breaks some libraries patched by auditwheel
      dontStrip = args.dontStrip or true;

      configurePhase =
        args.configurePhase or ''
          runHook preConfigure

          mkdir source
          cd source
          cp --no-preserve=mode ${pyproject} pyproject.toml
          cp --no-preserve=mode ${lock} uv.lock
          uvExport

          runHook postConfigure
        '';

      installPhase =
        args.installPhase or ''
          runHook preInstall

          uvInstall "$out" "$NIX_BUILD_TOP/requirements.txt" --compile-bytecode

          runHook postInstall
        '';

      passthru = {
        inherit python;
        uvWheels = uv.wheels;
        uvLock = parsedLock;
      }
      // lib.optionalAttrs (editableRoot != null) { inherit editable; }
      // passthru;

      meta = {
        inherit (python.meta) platforms;
        mainProgram = "python";
      }
      // meta;
    };
}
