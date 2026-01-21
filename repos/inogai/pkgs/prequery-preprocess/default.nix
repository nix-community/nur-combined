{
  lib,
  rustPlatform,
  fetchFromGitHub,
  openssl,
  pkg-config,
}:
rustPlatform.buildRustPackage rec {
  pname = "prequery-preprocess";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "typst-community";
    repo = "prequery-preprocess";
    rev = "v${version}";
    hash = "sha256-6IqwgU2j+siaeqfViE2L86xclWWhtLS8/mQghladPSg=";
  };

  cargoHash = "sha256-ohuhrHPyr/mgEIpBTAm65EcJVxiOYW3uwwn8/ZbpFs8=";

  nativeBuildInputs = [pkg-config];
  buildInputs = [openssl];

  meta = {
    description = "A preprocessor for prequery metadata embedded in Typst documents";
    homepage = "https://typst-community.github.io/prequery/";
    changelog = "https://github.com/typst-community/prequery-preprocess/releases";
    license = lib.licenses.mit;
    maintainers = [lib.maintainers.inogai];
    mainProgram = "prequery";
    platforms = lib.platforms.all;
  };
}
