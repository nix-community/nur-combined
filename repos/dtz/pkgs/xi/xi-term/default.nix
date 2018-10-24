{ lib, rustPlatform, fetchFromGitHub, wrapXiFrontendHook }:

rustPlatform.buildRustPackage rec {
  name = "xi-term-${version}";
  version = "2018-10-24";

  src = fetchFromGitHub {
    owner = "xi-frontend";
    repo = "xi-term";
    rev = "256358dd377ba447309be1db2321b5534fb9371b";
    sha256 = "1484gmsr58d8h68sppdz5yvwyc7ywj5g3fzh1krwwjznmkzz51zy";
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

