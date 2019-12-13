{ lib, fetchFromGitHub, buildGoModule
, version, rev, sha256, modSha256 }:

buildGoModule rec {
  name = "dtn7-go";
  inherit version modSha256;

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
