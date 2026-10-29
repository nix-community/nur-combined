{
  callPackage,
  fetchFromGitHub,
  writeShellApplication,
  coreutils,
  git,
  gnused,
  nix,
}:

let
  upstream = import ./upstream.nix { inherit fetchFromGitHub; };
  updateScript = writeShellApplication {
    name = "update-claude-desktop";
    runtimeInputs = [
      coreutils
      git
      gnused
      nix
    ];
    text = ''
      export UPDATE_NIX_ATTR_PATH="claude-desktop"
      exec ${./update.sh} "$@"
    '';
  };
  pkg = callPackage (upstream + "/nix/claude-desktop.nix") { };
in
pkg.overrideAttrs (prevAttrs: {
  passthru = (prevAttrs.passthru or { }) // {
    inherit updateScript;
  };
})
