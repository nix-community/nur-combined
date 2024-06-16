{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule rec {
  pname = "youtimetrack";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "bullshitsoftware";
    repo = "youtimetrack";
    rev = "v${version}";
    hash = "sha256-IeiDdobOgwYwQytzgoAWQEyNtnJNXeMiiMFnZ3t7GYE=";
  };

  vendorHash = "sha256-HRyjdTTwDmu/5NVpjqCwatYuWN15j3rTgrhv76uMS7I=";

  meta = {
    description = "CLI tools for YouTrack time management";
    homepage = "https://github.com/bullshitsoftware/youtimetrack";
    license = lib.licenses.wtfpl;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
