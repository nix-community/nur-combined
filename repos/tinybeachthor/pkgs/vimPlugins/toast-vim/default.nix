{ buildVimPluginFrom2Nix, fetchFromGitHub }:

buildVimPluginFrom2Nix rec {
  pname = "toast.vim";
  version = "2020-10-25";

  src = fetchFromGitHub {
    owner = "jsit";
    repo = pname;
    rev = "724f13606f213f0ab6fa4044b1c51945a424a9b1";
    sha256 = "sha256-ppA2WxeDuFk/eBCP+/GGuvAcmr/urCHKzb+44Lww5Xc=";
  };
}
