{
  callPackage,
  inputs,
  writeShellApplication,
  coreutils,
  git,
  gnused,
  nix,
}:

let
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
in
(
  if inputs.claudeDesktopUpstream != null then
    inputs.claudeDesktopUpstream
  else
    callPackage (inputs.claudeDesktopSrc + "/nix/claude-desktop.nix") { }
).overrideAttrs
  (prevAttrs: {
    passthru = (prevAttrs.passthru or { }) // {
      inherit updateScript;
    };
  })
