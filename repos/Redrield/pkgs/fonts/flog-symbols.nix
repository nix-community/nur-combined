{ stdenv, fetchFromGitHub, lib }:
stdenv.mkDerivation rec {
  pname = "flog-symbols";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "rbong";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-kGk1I3u9MT3E/yalNaNhopsItKsomcBfsoUUiccE+Tw=";
  };

  installPhase = "install -m444 -Dt $out/share/fonts/truetype FlogSymbols.ttf";
}
