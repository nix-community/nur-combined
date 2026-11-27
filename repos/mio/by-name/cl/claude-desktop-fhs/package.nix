{
  callPackage,
  inputs,
  claude-desktop,
}:

(
  if inputs.claudeDesktopFhsUpstream != null then
    inputs.claudeDesktopFhsUpstream
  else
    callPackage (inputs.claudeDesktopSrc + "/nix/fhs.nix") {
      inherit claude-desktop;
    }
).overrideAttrs
  (prevAttrs: {
    passthru = (prevAttrs.passthru or { }) // {
      inherit (claude-desktop.passthru) updateScript;
    };
  })
