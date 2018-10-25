{ lib, rustPlatform, fetchFromGitHub, wrapXiFrontendHook }:

rustPlatform.buildRustPackage rec {
  name = "xi-term-${version}";
  version = "2018-10-25";

  src = fetchFromGitHub {
    owner = "xi-frontend";
    repo = "xi-term";
    rev = "77eb8aadabf48fdc5b35af3025b10519159840b5";
    sha256 = "0wid9xy9q5g6mjnvp5a25mi3wa3ksxjnlpxkfhbkpfdqwjbysn4g";
  };

  cargoSha256 = "1h49j2r5bh1rjqmss6ccivc2x0ndmamqqzhi6kd02vgrv8jnwxg1";

  buildInputs = [ wrapXiFrontendHook ];

  postInstall = "wrapXiFrontend $out/bin/*";

  meta = with lib; {
    description = "A terminal frontend for Xi";
    homepage = https://github.com/xi-frontend/xi-term;
    license = licenses.mit;
    maintainers = with maintainers; [ dtzWill ];
    platforms = platforms.all;
  };
}

