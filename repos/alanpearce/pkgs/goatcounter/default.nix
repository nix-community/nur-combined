{ lib
, buildGoModule
, fetchFromGitHub

, withSQLite ? true
}:

buildGoModule rec {
  pname = "goatcounter";
  version = "2.5.0";

  src = fetchFromGitHub {
    owner = "arp242";
    repo = "goatcounter";
    rev = "v${version}";
    sha256 = "sha256-lwiLk/YYxX4QwSDjpU/mAikumGXYMzleRzmPjZGruZU=";
  };

  CGO_ENABLED = if withSQLite then 1 else 0;
  subPackages = [ "cmd/goatcounter" ];

  ldflags = [ "-X=zgo.at/goatcounter/v2.Version=${version}" ];

  doCheck = false;

  vendorHash = "sha256-YAb3uBWQc6hWzF1Z5cAg8RzJQSJV+6dkppfczKS832s=";

  meta = with lib; {
    description = "Easy web analytics. No tracking of personal data.";
    homepage = "https://www.goatcounter.com/";
    license = {
      spdxId = "LicenseRef-Goatcounter-EUPL-Modified";
      fullName = "European Union Public License (EUPL) 1.2 (modified)";
      url = "https://github.com/arp242/goatcounter/blob/master/LICENSE";
      free = true;
    };
    platforms = platforms.unix;
  };
}
