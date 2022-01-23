{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "nn";
  version = "0.0.1";

  src = fetchFromGitHub {
    owner = "meain";
    repo = "${pname}";
    rev = "${version}";
    sha256 = "sha256-SU0RoWIB9S4DByqLzfMJjJUZR3wEKmHwcF0Mb7BI0U8=";
  };

  vendorSha256 = "sha256-2PeaIokw6wG2JflU4+JlCtv1owkrojRATr0rG/4pAHc=";
  proxyVendor = true;

  meta = with lib; {
    description = " Quick little bot to run shell commands on servers via matrix";
    license = lib.licenses.asl20;
    homepage = "https://github.com/meain/${pname}";
    platforms = platforms.linux ++ platforms.darwin;
  };
}
