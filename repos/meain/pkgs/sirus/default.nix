{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "sirus";
  version = "0.0.7";

  src = fetchFromGitHub {
    owner = "meain";
    repo = "${pname}";
    rev = "${version}";
    sha256 = "sha256-0cyxl8TqKLZsTm2ead9u7fNM3ExvP+uCbF/bnLmqAxE=";
  };

  vendorSha256 = "sha256-9+ph6dI+Fjhde5wxo7saW9/tZUZdIIXlE0X1MGqrPbw=";
  proxyVendor = true;

  meta = with lib; {
    description = "Simple URL shortner";
    license = lib.licenses.asl20;
    homepage = "https://github.com/meain/${pname}";
    platforms = platforms.linux ++ platforms.darwin;
  };
}
