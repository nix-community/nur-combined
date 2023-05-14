{ lib
, rustPlatform
, fetchFromGitHub
}:

rustPlatform.buildRustPackage rec {
  pname = "qr2text";
  version = "0.1";

  src = fetchFromGitHub {
    owner = "ayosec";
    repo = "qr2text";
    rev = "v${version}";
    hash = "sha256-Xut6rQFN0szT5O/+C70Q3Kjo8AVVfwZlZEyWVxK1Pzw=";
  };

  cargoLock = {
    lockFile = ./Cargo.lock;
  };

  postPatch = ''
    ln -s ${./Cargo.lock} Cargo.lock
  '';

  meta = with lib; {
    description = "Render a QR code directly in the terminal";
    homepage = "https://github.com/ayosec/qr2text";
    changelog = "https://github.com/ayosec/qr2text/blob/${src.rev}/CHANGELOG.md";
    license = licenses.mit;
    maintainers = with maintainers; [ nagy ];
  };
}
