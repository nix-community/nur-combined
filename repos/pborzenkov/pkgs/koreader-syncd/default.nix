{
  lib,
  fetchFromGitHub,
  rustPlatform,
}:
rustPlatform.buildRustPackage rec {
  pname = "koreader-syncd";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "pborzenkov";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-5gViz57LB2qsTrW6BqoeqtVRmztshofg8PzQtZ1hnk0=";
  };

  cargoHash = "sha256-CIs8rClqKbt3mfmL+z1kDDEnCT/bbDZyMyGjkz+mwsQ=";

  meta = with lib; {
    description = "KOReader progress sync server";
    homepage = "https://github.com/pborzenkov/koreader-syncd";
    license = with licenses; [ mit ];
    maintainers = with maintainers; [ pborzenkov ];
  };
}
