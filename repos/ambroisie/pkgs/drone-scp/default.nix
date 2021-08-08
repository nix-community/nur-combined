{ lib, buildGoModule, fetchFromGitHub }:
buildGoModule rec {
  pname = "drone-scp";
  version = "1.6.2";

  src = fetchFromGitHub {
    owner = "appleboy";
    repo = "drone-scp";
    rev = "v${version}";
    sha256 = "sha256-PNy1HA2qW4RY/VRHhuj/tIrdTuB7COr0Cuzurku+DZw=";
  };

  vendorSha256 = "sha256-7Aro6g3Tka0Cbi9LpqvKpQXlbxnHQWsMOkkNpENKh0U=";

  doCheck = false; # Needs a specific user...

  meta = with lib; {
    description = ''
      Copy files and artifacts via SSH using a binary, docker or Drone CI
    '';
    homepage = "https://github.com/appleboy/drone-scp";
    license = licenses.mit;
  };
}
