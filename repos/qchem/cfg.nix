{
  # allow configuration via environment
  allowEnv ? false
, srcurl ? null
, optpath ? null
, licMolpro ? null
, optAVX ? false
} :

  let
  # getEnv that returns null if var is not set
  getEnv = x:
  let
    envVar = builtins.getEnv x;
  in
    if (builtins.stringLength envVar) > 0 then envVar
    else null;

  getValue = x: envVar:
    if allowEnv then
      if (getEnv envVar) != null then getEnv envVar else x
    else x;
in {
  # base url for non-free packages
  srcurl = getValue srcurl "NIXQC_SRCURL";

  # path to packages that reside outside the nix store
  optpath = getValue optpath "NIXQC_OPTPATH";

  # string containing a valid MOLPRO license token
  licMolpro = getValue licMolpro "NIXQC_LICMOLPRO";

  # turn of AVX optimizations in selected packages
  optAVX =  if allowEnv then
      if (getEnv "NIXQC_AVX") != null then (if (getEnv "NIXQC_AVX") == "1" then true else false) else optAVX
    else optAVX;
}
