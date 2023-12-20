{ stdenv
, lib
, fetchFromGitHub
, rustPlatform
, pkg-config
, openssl
, darwin
}:

rustPlatform.buildRustPackage rec {

  pname = "maa-cli";
  version = "0.4.0-beta.4";

  src = fetchFromGitHub {
    owner = "MaaAssistantArknights";
    repo = "maa-cli";
    rev = "v${version}";
    sha256 = "sha256-vjA8TGTXe69JuseYOz3wAkLxDVpiQ5zFyhHlUACjoYw=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    openssl
  ] ++ lib.optional stdenv.isDarwin [
    darwin.Security
  ];

  # https://github.com/MaaAssistantArknights/maa-cli/pull/126
  buildNoDefaultFeatures = true;
  buildFeatures = [ "git2" ];

  cargoSha256 = "sha256-77iRLjaacHy8OwtomdGt220dHit4Zcpq4JmANIU5r7o=";

  meta = with lib; {
    description = "A simple CLI for MAA by Rust.";
    homepage = "https://github.com/MaaAssistantArknights/maa-cli";
    license = licenses.agpl3;
    platforms = platforms.linux ++ platforms.darwin;
    maintainers = with maintainers; [ Cryolitia ];
    mainProgram = "maa";
  };

}
