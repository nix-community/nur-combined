{
  inputs',
  stdenv,
}:
inputs'.nvfetcher.packages.default.overrideAttrs (
  finalAttrs: prevAttrs: {
    passthru = (prevAttrs.passthru or { }) // {
      _ignoreOverride = true;
    };
  }
)
