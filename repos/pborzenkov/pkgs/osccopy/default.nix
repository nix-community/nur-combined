{
  lib,
  fetchFromGitHub,
  rustPlatform,
}:
rustPlatform.buildRustPackage rec {
  pname = "osccopy";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "pborzenkov";
    repo = "osccopy";
    rev = "v${version}";
    sha256 = "sha256-vBAAIBagBhjR5jVFZKhAKF9HJlua+g97k/YUrHD0pKk=";
  };

  cargoHash = "sha256-fHI3DTHUPtIG9Wj3d6aTaAnb5sDA7QyF5/fGUpalvus=";

  meta = with lib; {
    description = "Copy text from remote machine into local clipboard";
    homepage = "https://github.com/pborzenkov/osccopy";
    license = with licenses; [ mit ];
    maintainers = with maintainers; [ pborzenkov ];
  };
}
