{
  stdenv,
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule rec {
  pname = "mqcontrol";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "albertnis";
    repo = "mqcontrol";
    rev = "v${version}";
    hash = "sha256-rsmWrKOEJjd74ElsaR7Rk7FsY0wwSgG/AzYB5LcmWNQ=";
  };

  vendorHash = "sha256-tuSrIq2DHMy2KY2z3ZMAwC28UGHrZifAWmOFx5Y4pKU=";

  meta = with lib; {
    description = "Cross-platform utility to execute commands remotely using MQTT";
    inherit (src.meta) homepage;
    license = licenses.free;
    maintainers = [ maintainers.sikmir ];
  };
}
