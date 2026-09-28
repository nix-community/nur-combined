{
  pkgs,
  lib,
  runCommand,
  fetchFromGitHub,
  boost,
  cmake,
  pkg-config,
  SDL2,
  openal,
}:
let
  info = builtins.fromJSON (builtins.readFile ./sources.json);
  layout = builtins.fromJSON (builtins.readFile ./source-layout.json);
  src = fetchFromGitHub {
    owner = "KlugKlugTG";
    repo = "HyperHLE-Fork";
    inherit (info) rev hash;
    fetchSubmodules = true;
  };
  # Fixed-output slices keep unchanged local crates cached across upstream
  # revisions. Preserve the directory layout used by build.rs and C includes.
  sources = lib.mapAttrs (
    name: spec:
    runCommand "hyperhle-${name}-source"
      {
        outputHashMode = "recursive";
        outputHashAlgo = "sha256";
        outputHash = info.components.${name};
      }
      (
        ''
          mkdir -p "$out"
          cd ${src}
        ''
        + lib.concatMapStringsSep "\n" (path: ''
          mkdir -p "$out/$(dirname ${lib.escapeShellArg path})"
          cp -a ${lib.escapeShellArg path} "$out/${path}"
        '') ([ spec.path ] ++ spec.vendor)
      )
  ) layout;
  nativeOverrides = {
    touchHLE_dynarmic_wrapper = {
      nativeBuildInputs = [ cmake ];
      buildInputs = [ boost ];
    };
    touchHLE_libxml2_wrapper.nativeBuildInputs = [ cmake ];
    touchHLE_openal_soft_wrapper.propagatedBuildInputs = [ openal ];
  };
  overrides = lib.mapAttrs (
    name: spec: attrs:
    {
      src = sources.${name};
      workspace_member = spec.path;
    }
    // (nativeOverrides.${name} or { })
  ) layout;
  cargo = import ./Cargo.nix {
    inherit pkgs;
    rootFeatures = [ "touchHLE_libxml2_wrapper/static" ];
    buildRustCrateForPkgs =
      p:
      p.buildRustCrate.override {
        defaultCrateOverrides =
          (lib.genAttrs (lib.unique (map (c: c.crateName) (lib.attrValues cargo.internal.crates))) (
            name: attrs:
            ((p.defaultCrateOverrides.${name} or (_: { })) attrs)
            // {
              extraRustcOpts = [
                "-C"
                "embed-bitcode=yes"
              ];
            }
          ))
          // (lib.mapAttrs (
            _: override: attrs:
            (override attrs)
            // {
              extraRustcOpts = [
                "-C"
                "embed-bitcode=yes"
              ];
            }
          ) overrides)
          // {
            sdl2-sys = attrs: {
              nativeBuildInputs = [ pkg-config ];
              propagatedBuildInputs = [ SDL2 ];
              SDL2_LIB_DIR = "${lib.getLib SDL2}/lib";
            };
            touchHLE = attrs: {
              inherit src;
              workspace_member = ".";
              patches = [
                ./fix-sigsetjmp-exports.patch
                ./precomputed-licenses.patch
              ];
              postPatch = "cp ${./rust-dependencies.txt} rust-dependencies.txt";
              extraRustcOpts = [
                "-C"
                "embed-bitcode=yes"
              ];
            };
          };
      };
  };
in
cargo.workspaceMembers.touchHLE.build.overrideAttrs (old: {
  # buildRustCrate has one extraRustcOpts list for libraries and binaries.
  # Cargo applies fat LTO to the final binary, not the intermediate rlib.
  # Fail explicitly if the builder changes rather than silently losing LTO.
  buildPhase =
    assert lib.hasInfix ''BIN_RUSTC_OPTS="'' old.buildPhase;
    lib.replaceStrings [ ''BIN_RUSTC_OPTS="'' ] [ ''BIN_RUSTC_OPTS="-C lto=fat '' ] old.buildPhase;
  passthru = (old.passthru or { }) // {
    inherit src sources;
  };
})
