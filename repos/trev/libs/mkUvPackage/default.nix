# Builds a Python project that locks its dependencies with uv, installing the
# exact wheels in uv.lock into a virtual environment at $out.
#
# uv.lock records the URL and sha256 of every wheel, so they're read during
# evaluation and fetched with fetchurl, without a dependency hash to update.
# One wheel is picked per package for the interpreter and platform (see
# ./wheels.nix), and uv installs them offline from a flat index, evaluating the
# lock's markers and checking every hash again. Packages that only have sdists
# or no wheel for the platform aren't supported, unless they're excluded by
# markers or replaced with `overrides.<name>`: a nixpkgs Python package (its
# wheel in the `dist` output is used), a wheel or a directory of wheels.
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
# are in ./hook.sh, for custom phases.
#
# On Linux, autoPatchelfHook links the native extensions to libraries that
# auditwheel doesn't bundle (libstdc++), add others to `buildInputs`.
{
  autoPatchelfHook,
  cacert,
  fetchurl,
  lib,
  linkFarm,
  makeSetupHook,
  python3,
  stdenv,
  uv,
}:

let
  pickWheels = import ./wheels.nix { inherit lib; };

  hook = makeSetupHook { name = "mk-uv-package-hook"; } ./hook.sh;

  # https://packaging.python.org/en/latest/specifications/name-normalization/
  normalize =
    name:
    lib.toLower (
      lib.concatStringsSep "-" (
        lib.filter (part: lib.isString part && part != "") (builtins.split "[-_.]+" name)
      )
    );

  # the name of a requirement like `hatchling>=1.27` or `foo[bar]; extra == "x"`
  requirementName =
    requirement:
    let
      match = builtins.match "[[:space:]]*([A-Za-z0-9][A-Za-z0-9._-]*).*" requirement;
    in
    if match == null then
      throw "mkUvPackage: can't parse the build requirement '${requirement}'"
    else
      normalize (builtins.head match);

  # flags for uv export
  exportFlags =
    { groups, extras }:
    lib.concatLists (
      [
        [
          "--frozen"
          "--format=requirements.txt"
          "--no-emit-project"
          "--no-default-groups"
        ]
      ]
      ++ map (group: [ "--group=${group}" ]) groups
      ++ map (extra: [ "--extra=${extra}" ]) extras
    );
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

      # the root project, `virtual` if it has no build system
      project = lib.findFirst (
        package: (package.source.editable or package.source.virtual or null) == "."
      ) null (parsedLock.package or [ ]);
      isVirtual = project != null && project.source ? virtual;

      overrideNames = map normalize (lib.attrNames overrides);

      wheels =
        map
          (
            wheel:
            fetchurl {
              name = wheel.filename;
              inherit (wheel) url sha256;
            }
          )
          (
            lib.filter (wheel: !builtins.elem wheel.name overrideNames) (pickWheels {
              lock = parsedLock;
              inherit python;
              platform = stdenv.hostPlatform;
              libcVersion = if stdenv.hostPlatform.libc == "glibc" then stdenv.cc.libc.version else null;
            })
          );

      # uv parses the filenames of wheels in --find-links
      wheelIndex = linkFarm "${finalAttrs.pname}-wheels" (
        map (wheel: {
          inherit (wheel) name;
          path = wheel;
        }) wheels
      );

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

      # wheels of the overrides, found during the build
      overridePaths = map (package: package.dist or package) (lib.attrValues overrides);
    in
    {
      pname = args.pname or project.name or (throw "mkUvPackage: pname is required");
      version = args.version or project.version or (throw "mkUvPackage: version is required");

      inherit doCheck;

      nativeBuildInputs = [
        uv
        hook
      ]
      ++ lib.optional stdenv.hostPlatform.isLinux autoPatchelfHook
      ++ nativeBuildInputs;

      # auditwheel doesn't bundle libstdc++ and libgcc_s
      buildInputs = lib.optional stdenv.hostPlatform.isLinux stdenv.cc.cc.lib ++ buildInputs;

      # stripping breaks some libraries patched by auditwheel
      dontStrip = args.dontStrip or true;

      env = {
        UV_NO_PROGRESS = "1";
        UV_OFFLINE = "1";
        UV_PYTHON_DOWNLOADS = "never";
        UV_LINK_MODE = "copy";
        # uv loads certificates even offline, and warns about stdenv's placeholder
        SSL_CERT_FILE = "${cacert}/etc/ssl/certs/ca-bundle.crt";
      }
      // args.env or { };

      uvPython = python.interpreter;
      uvWheelIndex = wheelIndex;
      uvOverrides = overridePaths;
      uvExportFlags = exportFlags {
        groups = [ ];
        inherit extras;
      };
      uvCheckExportFlags = exportFlags { inherit groups extras; };
      uvExcludeFlags = map (name: "--no-emit-package=${name}") overrideNames;

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
        uvWheels = wheels;
        uvLock = parsedLock;
      }
      // passthru;

      meta = {
        inherit (python.meta) platforms;
      }
      // meta;
    };
}
