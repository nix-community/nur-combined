{ lib, fetchFromGitHub, buildGoModule
, version, rev, sha256, vendorSha256 }:

buildGoModule rec {
  pname = "dtn7-go";
  inherit version vendorSha256;

  src = fetchFromGitHub {
    inherit rev sha256;
    owner = "dtn7";
    repo = "dtn7-go";
  };

  meta = with lib; {
    description = "Delay-tolerant networking software suite, Bundle Protocol Version 7";
    homepage = "https://github.com/dtn7/dtn7-go";
    license = licenses.gpl3;
    maintainers = with maintainers; [ geistesk ];
  };
}
