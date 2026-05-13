{
  nvfetcher-bin ? null,
}:

if nvfetcher-bin == null then
  null
else
  nvfetcher-bin.overrideAttrs (
    finalAttrs: prevAttrs: {
      passthru = (prevAttrs.passthru or { }) // {
        _ignoreOverride = true;
      };
    }
  )
