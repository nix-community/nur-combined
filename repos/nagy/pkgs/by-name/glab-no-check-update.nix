{
  lib,
  glab,
  writeText,
}:

let
  glabNoCheckUpdatePatch = writeText "glab-no-check-update.patch" ''
    --- a/cmd/glab/main.go
    +++ b/cmd/glab/main.go
    @@ -211,23 +211,8 @@
     }
     
     func isUpdateCheckEnabled(f cmdutils.Factory) bool {
    -	if enabled, found := utils.IsEnvVarEnabled("GLAB_CHECK_UPDATE"); found {
    -		return enabled
    -	}
    -
    -	val, err := f.Config().Get("", "check_update")
    -	// WARN: I return true here since I think we should always check for updates
    -	// and an error likely indicates that the value wasn't found in the config.
    -	if err != nil || val == "" {
    -		return true
    -	}
    -
    -	checkUpdate, err := strconv.ParseBool(val)
    -	if err != nil {
    -		f.IO().LogErrorf("ERROR: Could not parse config value %q: %s", "check_update", err)
    -	}
    -
    -	return checkUpdate
    +	// Permanently disabled in nur-packages: behaves as if `check_update: false`.
    +	return false
     }
     
     func preprocessCommandLinks(cmd *cobra.Command, io *iostreams.IOStreams) {
  '';
in
glab.overrideAttrs (finalAttrs: previous: {
  pname = "glab-no-check-update";

  patches = (previous.patches or [ ]) ++ [
    glabNoCheckUpdatePatch
  ];

  meta = (previous.meta or { }) // {
    description = "${previous.meta.description}: update checking permanently disabled";
  };
})
