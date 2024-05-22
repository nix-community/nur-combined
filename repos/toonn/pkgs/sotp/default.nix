{ buildGoModule
, fetchFromGitHub
, gnupg
, lib
}:

buildGoModule rec {
  pname = "sotp";
  version = "1.0.0-unstable-2024-05-20";

  src = fetchFromGitHub {
    owner = "getsops";
    repo = "sotp";
    rev = "13b0f90378a9f805806a2f5a87c4ed4afb8e877e";
    hash = "sha256-OuUnjT0yZrZtpfhMCMqaPZMDTVBynTWTLnGaCsdWeu4=";
  };

  vendorHash = "sha256-78dS9GPuQ7HdDufql8QYxbRm6sgajd5kGiaKW6x7lTI=";

  nativeCheckInputs = [ gnupg ];

  # The tests assume the GPG key is already available in the keyring.
  preCheck = ''
    mkdir --mode=700 gnupghome-sotp-test
    export GNUPGHOME=gnupghome-sotp-test
    gpg --import sops_functional_tests_key.asc
  '';

  meta = with lib; {
    description = "Small utility to store AWS TOTP secrets into Sops encrypted"
                + "files and generate OTP on the command line";
    homepage = "https://github.com/getsops/sotp";
    license = with licenses; unfree;
    mainProgram = "sotp";
    maintainers = with maintainers; [ toonn ];
  };
}
