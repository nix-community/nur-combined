{
  lib,
  nixpkgs,
  importNpmLock,

  sources,
  source ? sources.nezha-theme-admin,
}:
nixpkgs.nezha-theme-admin.overrideAttrs (
  finalAttrs: prevAttrs: {
    inherit (source) version src;

    nativeBuildInputs =
      (lib.filter (x: x != nixpkgs.npmHooks.npmConfigHook) prevAttrs.nativeBuildInputs)
      ++ [ finalAttrs.npmConfigHook ];
    npmConfigHook = importNpmLock.npmConfigHook;
    npmDeps = importNpmLock {
      package = lib.importJSON source.extract."package.json";
      packageLock = lib.importJSON ./package-lock.json;
    };

    # nix-update auto -u

    passthru = (prevAttrs.passthru or { }) // {
      _ignoreOverride = true;
    };
  }
)
