{
  callPackage,
  fetchFromGitHub,
  claude-desktop,
}:

let
  upstream = import ../claude-desktop/upstream.nix { inherit fetchFromGitHub; };
  fhs = callPackage (upstream + "/nix/fhs.nix") {
    inherit claude-desktop;
  };
in
fhs.overrideAttrs (prevAttrs: {
  passthru = (prevAttrs.passthru or { }) // {
    inherit (claude-desktop.passthru) updateScript;
  };
})
