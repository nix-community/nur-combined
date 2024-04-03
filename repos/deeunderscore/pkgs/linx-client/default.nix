{ stdenv, lib, buildGoModule, fetchFromGitHub }:
buildGoModule rec {
  pname = "linx-client";
  # stable v1.5.2 does not support Go modules
  version = "unstable-2020-10-17";

  src = fetchFromGitHub {
    owner = "andreimarcu";
    repo = "linx-client";
    rev = "d259a0c51d56ccfef1906ac0dfcf50ee6819c5eb";
    sha256 = "sha256-QptwZlh7YJiDz7EsOhx7DLreiq/QcH1fRKHpu4s6nZk=";
  };
  
  vendorHash= "sha256-3bzJgS5Vzo3pvHmFT+zSiiw/1/LxC1pLPFVPmSzt+iE=";

  meta = {
    description = "Client for linx-server";
    homepage = "https://github.com/andreimarcu/linx-client";
    license = lib.licenses.gpl3Plus;
  };
}
