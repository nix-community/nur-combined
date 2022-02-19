{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "sirus";
  version = "0.0.1";

  src = fetchFromGitHub {
    owner = "meain";
    repo = "${pname}";
    rev = "${version}";
    sha256 = "sha256-vnuut1YrqM+Vs9whO4BHt67vxhoWYosFoj5lrCoClgE=";
  };

  vendorSha256 = "sha256:057cyq0y0cbdb81sdvcqipfafwa62g1qp5fpjqlccs4961f2w1cr";
  proxyVendor = true;

  meta = with lib; {
    description = "Simple URL shortner";
    license = lib.licenses.asl20;
    homepage = "https://github.com/meain/${pname}";
    platforms = platforms.linux ++ platforms.darwin;
  };
}
