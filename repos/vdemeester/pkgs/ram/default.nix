{ stdenv, lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  name = "ram-${version}";
  version = "0.3.0";
  rev = "v${version}";

  src = fetchFromGitHub {
    inherit rev;
    owner = "vdemeester";
    repo = "ram";
    sha256 = "1lnxscq6lfli09yq5raj2gyg7fss4a8m99nd6f1izm84xn0n0lji";
  };
  vendorSha256 = "1rynwivgc9ilsixri8vcxss20j8wpns1jw9g0k37lgdqx88wpl9y";
  modSha256 = "${vendorSha256}";

  meta = {
    description = "A golang opiniated continuous testing tool 🐏";
    homepage = "https://github.com/vdemeester/ram";
    license = lib.licenses.asl20;
  };
}
