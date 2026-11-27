{
  callPackage,
  inputs,
  stdenv,
  writeShellApplication,
  coreutils,
  git,
  gnused,
  nix,
}:

let
  upstreamPackages = inputs."claude-desktop-src".packages.${stdenv.hostPlatform.system} or { };
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
  if builtins.hasAttr "claude-desktop" upstreamPackages then
    upstreamPackages.claude-desktop
  else
    callPackage (inputs."claude-desktop-src" + "/nix/claude-desktop.nix") { }
).overrideAttrs
  (prevAttrs: {
    passthru = (prevAttrs.passthru or { }) // {
      inherit updateScript;
    };
  })
