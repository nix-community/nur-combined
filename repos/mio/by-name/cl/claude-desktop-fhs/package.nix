{
  callPackage,
  inputs,
  claude-desktop,
  stdenv,
}:

let
  upstreamPackages = inputs."claude-desktop-src".packages.${stdenv.hostPlatform.system} or { };
in
(
  if builtins.hasAttr "claude-desktop-fhs" upstreamPackages then
    upstreamPackages.claude-desktop-fhs
  else
    callPackage (inputs."claude-desktop-src" + "/nix/fhs.nix") {
      inherit claude-desktop;
    }
).overrideAttrs
  (prevAttrs: {
    passthru = (prevAttrs.passthru or { }) // {
      inherit (claude-desktop.passthru) updateScript;
    };
  })
