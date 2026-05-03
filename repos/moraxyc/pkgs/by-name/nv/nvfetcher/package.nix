{
  inputs,
  stdenv,
}:

let
  nvfetcher = inputs.nvfetcher.packages.${stdenv.hostPlatform.system}.default or null;
in
if nvfetcher == null then
  null
else
  nvfetcher.overrideAttrs (
    finalAttrs: prevAttrs: {
      passthru = (prevAttrs.passthru or { }) // {
        _ignoreOverride = true;
      };
    }
  )
