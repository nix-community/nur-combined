self: super:
let
  overrideSuperVersionIfNewer = superPackage: localPackage:
    if super.lib.versionAtLeast superPackage.version localPackage.version then
      superPackage
    else
      localPackage;
in
rec {
  nlohmann_json = overrideSuperVersionIfNewer super.nlohmann_json (super.nlohmann_json.overrideAttrs(oldAttrs: rec {
    version = "3.9.1";
    src = super.fetchFromGitHub {
      owner = "nlohmann";
      repo = "json";
      rev = "v${version}";
      sha256 = "0ar4mzp53lskxw3vdzw07f47njcshl3lwid9jfq6l7yx6ds2nyjc";
    };
  }));
}
