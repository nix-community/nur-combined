{
  getAppInfo = {
    lib,
    mozSupportedApps,
    mozPlatforms,
    mozApp,
    mozAppName ? mozApp.pname,
    mozAppVersion ? lib.getVersion mozApp,
    ...
  }: let
    name = lib.toLower mozAppName;
  in
    mozSupportedApps.${name}
    // rec {
      inherit name;
      version = mozAppVersion;
      major = builtins.head (builtins.match "([^.]+)\\..*" version);
      isESR = (builtins.match ".*esr" version) != null;
      majorKey = major + lib.optionalString isESR "esr";
      arch = mozPlatforms.${mozApp.system} or "";
      langpackBaseName = "${name}${lib.optionalString isESR "-esr"}-langpack";
    };
}
