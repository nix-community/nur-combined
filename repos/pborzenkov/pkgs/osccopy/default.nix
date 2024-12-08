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
    sha256 = "1ad4yiqaq57njdxhzylsbck4fpr882l68i9mwv8ih1m02qh0045w";
  };

  cargoHash = "sha256-VnY0hPJhWanQIk17byOhyYC1BwG07iX0zFbghxIy3vM=";

  meta = with lib; {
    description = "Copy text from remote machine into local clipboard";
    homepage = "https://github.com/pborzenkov/osccopy";
    license = with licenses; [mit];
    maintainers = with maintainers; [pborzenkov];
  };
}
