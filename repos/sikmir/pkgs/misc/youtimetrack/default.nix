{ stdenv, lib, fetchFromGitHub, buildGoModule }:

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

  meta = with lib; {
    description = "CLI tools for YouTrack time management";
    inherit (src.meta) homepage;
    license = licenses.wtfpl;
    maintainers = [ maintainers.sikmir ];
  };
}
