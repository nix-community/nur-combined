{ lib, buildGoModule, fetchgit }:

buildGoModule rec {
  pname = "unflac";
  version = "f06325e5c9e7875ddab4a2b703ef67c65ebf4823";

  src = fetchgit {
    url = "https://git.sr.ht/~ft/unflac";
    rev = "${version}";
    sha256 = "0slq9np4qla7m2yazvfmxkzfihgpx7s1rdvyad8h0rd8idadwvw8";
  };

  vendorSha256 = "0z7cfzqmm7bsmx32m1l1c9k0jd3lggbwhv5gf2v34agj7midnv44";
  runVend = true;

  doCheck = false;

  meta = with lib; {
    homepage = "https://sr.ht/~ft/unflac/";
    description =
      "A command line tool for fast frame accurate audio image + cue sheet splitting.";
    license = licenses.unfree;
  };
}
