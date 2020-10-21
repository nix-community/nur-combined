{ buildVimPluginFrom2Nix, fetchFromGitHub }:

buildVimPluginFrom2Nix rec {
  pname = "vrod";
  version = "2015-08-14";

  src = fetchFromGitHub {
    owner = "MicahElliott";
    repo = pname;
    rev = "d0f598051530005c0dd868dea1900f803c82086b";
    sha256 = "sha256-WiVeCXlwjb51/494IIFgMucje6Tqhg9+OJDg9gJngXc=";
  };

  meta = {
    broken = true;
  };
}
