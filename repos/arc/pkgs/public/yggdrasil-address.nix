{ lib
, stdenvNoCC
, fetchFromGitHub
, buildGoModule
, calculateYggdrasilAddress
}: with lib; buildGoModule rec {
  pname = "yggdrasil-address";
  version = "0.0.1";

  src = fetchFromGitHub {
    owner = "arcnmx";
    repo = pname;
    rev = "v${version}";
    sha256 = "1q3174fdskhp1d8vbg3jsf41gd69g1k4k0jjvkhy374i5nx4lrnb";
  };

  vendorSha256 = "031dc5mz5j5cyh0h3r8fxfsaimxcvdh8i1gk6934lmbc1ykrvqrs";

  passthru = {
    importWithPublicKey = pubkey: (calculateYggdrasilAddress pubkey).import;
  };
}
