{ lib, fetchFromGitHub, rustPlatform }:

rustPlatform.buildRustPackage rec {
  pname = "mmtc";
  version = "0.2.12";

  src = fetchFromGitHub {
    owner = "figsoda";
    repo = pname;
    rev = "v${version}";
    sha256 = "1chcnv8wql6v2vckpzvq6sxgpss7mnxaj008jdm8xalhw9d496s4";
  };

  cargoSha256 = "06b0hag3s5irvi57n0hc97agfw4sw783lkkl1b26iap6mfbvrqma";

  meta = with lib; {
    description = "Minimal mpd terminal client that aims to be simple yet highly configurable";
    homepage = "https://github.com/figsoda/mmtc";
    license = licenses.mpl20;
    maintainers = [ ];
    changelog = "https://raw.githubusercontent.com/figsoda/mmtc/v${version}/CHANGELOG.md";
  };
}
