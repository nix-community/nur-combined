{
  # allow configuration via environment
  allowEnv ? false
, srcurl ? null
, optpath ? null
, licMolpro ? null
, prefix ? null
, optAVX ? null
, useCuda ? null
} :

  let
  # getEnv that returns null if var is not set
  getEnv = x:
  let
    envVar = builtins.getEnv x;
  in
    if (builtins.stringLength envVar) > 0 then envVar
    else null;

  getValue = x: default: envVar:
    if x != null then x
    else if allowEnv then
    if (getEnv envVar) != null then getEnv envVar else default else default;

  getBoolValue = x: default: envVar:
    if x != null then x
    else if allowEnv then
      if (getEnv envVar) != null then
        (if (getEnv envVar) == "1" then true else false)
      else default
    else default;

 in {

  # Put the package set under prefix
  prefix = getValue prefix "qchem" "NIXQC_PREFIX";

  # base url for non-free packages
  srcurl = getValue srcurl null "NIXQC_SRCURL";

  # path to packages that reside outside the nix store
  optpath = getValue optpath null "NIXQC_OPTPATH";

  # string containing a valid MOLPRO license token
  licMolpro = getValue licMolpro null "NIXQC_LICMOLPRO";

  # turn of AVX optimizations in selected packages
  optAVX = getBoolValue optAVX true "NIXQC_AVX";

  # Enable CUDA on selected packages
  useCuda = getBoolValue useCuda false "NIXQC_CUDA";
}
