# Builds a Python project that locks its dependencies with uv, installing the
# exact wheels in uv.lock into a virtual environment at $out.
#
# uv.lock records the URL and sha256 of every wheel, so they're read during
# evaluation and fetched with fetchurl, without a dependency hash to update.
# One wheel is picked per package for the interpreter and platform (see
# ../uvHook/wheels.nix), and uv installs them offline from a flat index,
# evaluating the lock's markers and checking every hash again. Packages that
# only have sdists or no wheel for the platform aren't supported, unless they're
# excluded by markers or replaced with `overrides.<name>`: a nixpkgs Python
# package (its wheel in the `dist` output is used), a wheel or a directory of
# wheels.
#
# The project itself is built with its build backend from nixpkgs, as uv.lock
# doesn't lock build systems. The backend is picked from the requirements in
# pyproject.toml's [build-system] (uv_build is uv-build-latest), or set with
# `build-system`. Virtual projects (no build system) aren't built, only their
# dependencies are installed.
#
# With `doCheck` (the default), a separate environment with the dependency
# `groups` is created at the end of the build phase (`uvCheckEnv`) and activated
# for the check phase, which runs pytest if it's installed. The shell functions
# are in ../uvHook/hook.sh, for custom phases.
#
# On Linux, autoPatchelfHook links the native extensions to libraries that
# auditwheel doesn't bundle (libstdc++), add others to `buildInputs`.
{
  callPackage,
  lib,
  python3,
  stdenv,
}:

let
  uvHook = callPackage ../uvHook { };

  # the name of a requirement like `hatchling>=1.27` or `foo[bar]; extra == "x"`
  requirementName =
    requirement:
    let
      match = builtins.match "[[:space:]]*([A-Za-z0-9][A-Za-z0-9._-]*).*" requirement;
    in
    if match == null then
      throw "mkUvPackage: can't parse the build requirement '${requirement}'"
    else
      uvHook.normalize (builtins.head match);
in

lib.extendMkDerivation {
  constructDrv = stdenv.mkDerivation;

  excludeDrvArgNames = [
    "lock"
    "python"
    "groups"
    "extras"
    "build-system"
    "overrides"
  ];

  extendDrvArgs =
    finalAttrs:
    {
      src,
      # read during evaluation, IFD if `src` is a derivation
      lock ? "${src}/uv.lock",
      python ? python3,
      # dependency groups to install for the check phase
      groups ? [ ],
      # optional dependencies to install
      extras ? [ ],
      # build requirements of the project, read from pyproject.toml by default
      build-system ? null,
      # packages to use instead of the ones in uv.lock, by name
      overrides ? { },
      nativeBuildInputs ? [ ],
      buildInputs ? [ ],
      doCheck ? true,
      passthru ? { },
      meta ? { },
      ...
    }@args:
    let
      parsedLock = lib.importTOML lock;

      project = uvHook.findProject parsedLock;
      isVirtual = project != null && project.source ? virtual;

      uv = uvHook.drvAttrs {
        inherit (finalAttrs) pname;
        lock = parsedLock;
        inherit python overrides;
        exportFlags = uvHook.exportFlags {
          groups = [ ];
          inherit extras;
        };
        inherit nativeBuildInputs buildInputs;
        env = args.env or { };
      };

      # PEP 517's default for projects without [build-system]
      buildRequirements =
        (lib.importTOML "${src}/pyproject.toml").build-system.requires or [ "setuptools>=40.8.0" ];

      buildSystem =
        if build-system != null then
          build-system
        else
          map (
            requirement:
            let
              name = requirementName requirement;
            in
            if name == "uv-build" then
              python.pkgs.uv-build-latest or (python.pkgs.callPackage ../../packages/uv-build { })
            else
              python.pkgs.${name}
                or (throw "mkUvPackage: the build requirement '${name}' isn't in nixpkgs, set build-system")
          ) buildRequirements;

      buildPython = python.withPackages (_: [ python.pkgs.build ] ++ buildSystem);
    in
    uv.attrs
    // {
      pname = args.pname or project.name or (throw "mkUvPackage: pname is required");
      version = args.version or project.version or (throw "mkUvPackage: version is required");

      inherit doCheck;

      # stripping breaks some libraries patched by auditwheel
      dontStrip = args.dontStrip or true;

      uvCheckExportFlags = uvHook.exportFlags { inherit groups extras; };

      uvBuildPython = if isVirtual then "" else buildPython.interpreter;

      configurePhase =
        args.configurePhase or ''
          runHook preConfigure

          ${lib.optionalString (args ? lock) ''
            cp --no-preserve=mode ${lock} uv.lock
          ''}
          uvExport

          runHook postConfigure
        '';

      buildPhase =
        args.buildPhase or ''
          runHook preBuild

          uvBuild
          if [ -n "''${doCheck-}" ]; then
            uvCheckEnv
          fi

          runHook postBuild
        '';

      checkPhase =
        args.checkPhase or ''
          runHook preCheck

          if [ -x "$VIRTUAL_ENV/bin/pytest" ]; then
            pytest
          fi

          runHook postCheck
        '';

      installPhase =
        args.installPhase or ''
          runHook preInstall

          uvInstall "$out" "$NIX_BUILD_TOP/requirements.txt" --compile-bytecode

          runHook postInstall
        '';

      passthru = {
        inherit python buildPython;
        uvWheels = uv.wheels;
        uvLock = parsedLock;
      }
      // passthru;

      meta = {
        inherit (python.meta) platforms;
      }
      // meta;
    };
}
