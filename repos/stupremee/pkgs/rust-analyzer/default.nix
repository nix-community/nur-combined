{ lib, stdenv, fetchFromGitHub, rustPlatform, darwin }:

rustPlatform.buildRustPackage rec {
  pname = "rust-analyzer";
  version = "2020-11-30";
  rev = version;
  cargoSha256 = "sha256-M/4eJvRO3eeRw+1s5lqyWyES6BFEwep/S4EOJ2BOrvs=";

  src = fetchFromGitHub {
    owner = "rust-analyzer";
    repo = "rust-analyzer";
    sha256 = "sha256-A37vYy78q3jb7Ces+6U8XszoPCMgBcFR82fDfXyilvk=";
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
