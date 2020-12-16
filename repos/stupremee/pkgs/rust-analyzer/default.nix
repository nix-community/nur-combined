{ lib, stdenv, fetchFromGitHub, rustPlatform, darwin }:

rustPlatform.buildRustPackage rec {
  pname = "rust-analyzer";
  version = "2020-12-14";
  rev = version;
  cargoSha256 = "sha256-Np9lq4LDseRHiBKrIhoE5MkNr/mzbGpFzB3jNk4GASQ=";

  src = fetchFromGitHub {
    owner = "rust-analyzer";
    repo = "rust-analyzer";
    sha256 = "sha256-Onstk5zuQXVE+4pTAh0S5H9nnEPm6gnfbJ7fkM08Mq0=";
    inherit rev;
  };

  buildAndTestSubdir = "crates/rust-analyzer";

  nativeBuildInputs = [ rustPlatform.rustcSrc ];

  buildInputs = lib.optionals stdenv.hostPlatform.isDarwin
    [ darwin.apple_sdk.frameworks.CoreServices ];

  RUST_ANALYZER_REV = rev;

  doCheck = false;
  preCheck = ''
    fakeRustup=$(mktemp -d)
    ln -s $(command -v true) $fakeRustup/rustup
    export PATH=$PATH''${PATH:+:}$fakeRustup
    export RUST_SRC_PATH=${rustPlatform.rustcSrc}
  '';

  doInstallCheck = false;
  installCheckPhase = ''
    runHook preInstallCheck
    versionOutput="$($out/bin/rust-analyzer --version)"
    echo "'rust-analyzer --version' returns: $versionOutput"
    [[ "$versionOutput" == "rust-analyzer ${rev}" ]]
    runHook postInstallCheck
  '';

  meta = with stdenv.lib; {
    description =
      "An experimental modular compiler frontend for the Rust language";
    homepage = "https://github.com/rust-analyzer/rust-analyzer";
    license = with licenses; [ mit asl20 ];
  };
}
