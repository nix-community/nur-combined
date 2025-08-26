{ lib, stdenv
, darwin

, fetchFromGitHub

, rustPlatform

, pkg-config

, openssl

, enableDistClient ? true
, enableDistServer ? true
}:
rustPlatform.buildRustPackage rec {
  pname = "sccache";
  version = "0.10.0";

  src = fetchFromGitHub {
    owner = "mozilla";
    repo = "sccache";
    rev = "v${version}";
    sha256 = "sha256-VEDMeRFQKNPS3V6/DhMWxHR7YWsCzAXTzp0lO+COl08=";
  };

  cargoHash = "sha256-1kfKBN4uRbU5LjbC0cLgMqoGnOSEAdC0S7EzXlfaDPo=";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    openssl
  ] ++ lib.optionals stdenv.hostPlatform.isDarwin (with darwin.apple_sdk.frameworks; [
    Security
    SystemConfiguration
  ]);

  buildFeatures =
    lib.optional enableDistClient "dist-client"
    ++ lib.optional enableDistServer "dist-server";

  # Tests fail because of client server setup which is not possible inside the
  # pure environment, see https://github.com/mozilla/sccache/issues/460
  doCheck = false;

  meta = with lib; {
    description = "Ccache with Cloud Storage";
    mainProgram = "sccache";
    homepage = "https://github.com/mozilla/sccache";
    changelog = "https://github.com/mozilla/sccache/releases/tag/v${version}";
    license = licenses.asl20;
  };

}
