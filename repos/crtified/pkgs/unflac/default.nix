{ lib, buildGoModule, fetchgit }:

buildGoModule rec {
  pname = "unflac";
  version = "f7506edc9b820a727a18b358c7e42a16399a0958";

  src = fetchgit {
    url = "https://git.sr.ht/~ft/unflac";
    rev = "${version}";
    hash = "sha256-bkEExEQlDQEYRTlkagZffzXbDb9ehUrOHXFhf3Qu28s=";
  };

  vendorSha256 = "sha256-rmPOYxKWwZGhl/NM7CaaYUpI6hK8zJ6L2+9ol9ke+Qc=";
  proxyVendor = true;

  doCheck = false;

  meta = with lib; {
    homepage = "https://sr.ht/~ft/unflac/";
    description =
      "A command line tool for fast frame accurate audio image + cue sheet splitting.";
    license = licenses.unfree;
  };
}
