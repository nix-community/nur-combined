{ buildGoModule
, fetchFromGitHub
, gnupg
, lib
}:

buildGoModule rec {
  pname = "sotp";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "getsops";
    repo = "sotp";
    rev = version;
    hash = "sha256-fYzKqsxZmHv16+tlmROPB++QZaQYvWgeZqwiIMTLyak=";
  };

  proxyVendor = true;
  vendorHash = "sha256-byBYy/PFMY2xYXxdOCZnfAIby23ppEat3rs0ji7g5bA=";

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
