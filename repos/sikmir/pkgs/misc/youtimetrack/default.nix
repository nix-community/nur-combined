{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "youtimetrack";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "bullshitsoftware";
    repo = "youtimetrack";
    tag = "v${finalAttrs.version}";
    hash = "sha256-MZzXeCMlSLriDKg8yqeOzJBA5T47ImKjr+Mdu/wUjzU=";
  };

  vendorHash = "sha256-HRyjdTTwDmu/5NVpjqCwatYuWN15j3rTgrhv76uMS7I=";

  __darwinAllowLocalNetworking = true;

  meta = {
    description = "CLI tools for YouTrack time management";
    homepage = "https://github.com/bullshitsoftware/youtimetrack";
    license = lib.licenses.wtfpl;
    maintainers = [ lib.maintainers.sikmir ];
  };
})
