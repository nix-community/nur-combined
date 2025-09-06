{ fetchFromGitHub }:
rec {
  version = "1.18.0";

  src = fetchFromGitHub {
    owner = "Luzifer";
    repo = "ots";
    rev = "v${version}";
    hash = "sha256-vNuUmsSBmGtpxQeWLN1UziPF36WxngTRn415kMu193E=";
  };
}
