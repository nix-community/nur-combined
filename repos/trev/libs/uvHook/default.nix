# Shared by mkUvPackage and mkUvEnv: the setup hook with the shell functions
# (./hook.sh), and the derivation attributes it reads, for the wheels in uv.lock
# picked by ./wheels.nix.
{
  autoPatchelfHook,
  cacert,
  fetchurl,
  lib,
  linkFarm,
  makeSetupHook,
  stdenv,
  uv,
}:

let
  pickWheels = import ./wheels.nix { inherit lib; };

  hook = makeSetupHook { name = "uv-hook"; } ./hook.sh;

  # https://packaging.python.org/en/latest/specifications/name-normalization/
  normalize =
    name:
    lib.toLower (
      lib.concatStringsSep "-" (
        lib.filter (part: lib.isString part && part != "") (builtins.split "[-_.]+" name)
      )
    );

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

{
  inherit pickWheels normalize exportFlags;

  # the root project of a parsed lock, `virtual` if it has no build system
  findProject =
    lock:
    lib.findFirst (package: (package.source.editable or package.source.virtual or null) == ".") null (
      lock.package or [ ]
    );

  # the derivation attributes for the hook, that install the requirements of the
  # lock exported with `exportFlags` (uvExportFlags), replacing the `overrides`
  # with their wheels
  drvAttrs =
    {
      pname,
      lock,
      python,
      overrides,
      exportFlags,
      nativeBuildInputs,
      buildInputs,
      env,
    }:
    let
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
              inherit lock python;
              platform = stdenv.hostPlatform;
              libcVersion = if stdenv.hostPlatform.libc == "glibc" then stdenv.cc.libc.version else null;
            })
          );
    in
    {
      inherit wheels;

      attrs = {
        nativeBuildInputs = [
          uv
          hook
        ]
        ++ lib.optional stdenv.hostPlatform.isLinux autoPatchelfHook
        ++ nativeBuildInputs;

        # auditwheel doesn't bundle libstdc++ and libgcc_s
        buildInputs = lib.optional stdenv.hostPlatform.isLinux stdenv.cc.cc.lib ++ buildInputs;

        env = {
          UV_NO_PROGRESS = "1";
          UV_OFFLINE = "1";
          UV_PYTHON_DOWNLOADS = "never";
          UV_LINK_MODE = "copy";
          # uv loads certificates even offline, and warns about stdenv's placeholder
          SSL_CERT_FILE = "${cacert}/etc/ssl/certs/ca-bundle.crt";
        }
        // env;

        uvPython = python.interpreter;
        # uv parses the filenames of wheels in --find-links
        uvWheelIndex = linkFarm "${pname}-wheels" (
          map (wheel: {
            inherit (wheel) name;
            path = wheel;
          }) wheels
        );
        # wheels of the overrides, found during the build
        uvOverrides = map (package: package.dist or package) (lib.attrValues overrides);
        uvExportFlags = exportFlags;
        uvExcludeFlags = map (name: "--no-emit-package=${name}") overrideNames;
      };
    };
}
