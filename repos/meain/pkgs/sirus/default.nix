{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "sirus";
  version = "0.0.3";

  src = fetchFromGitHub {
    owner = "meain";
    repo = "${pname}";
    rev = "${version}";
    sha256 = "sha256-aGdcSscnMOipeHkxFWZ2+/KwPrLr4u0Dx65uk9oQ8KE=";
  };

  vendorSha256 = "sha256-zoC2zTDtI1bRYMnPfx7dt/d32QSAsHyrsP/1/Bf+/lY=";
  proxyVendor = true;

  meta = with lib; {
    description = "Simple URL shortner";
    license = lib.licenses.asl20;
    homepage = "https://github.com/meain/${pname}";
    platforms = platforms.linux ++ platforms.darwin;
  };
}
