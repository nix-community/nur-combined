{ lib, rustPlatform, fetchFromGitHub, wrapXiFrontendHook }:

rustPlatform.buildRustPackage rec {
  name = "xi-term-${version}";
  version = "2018-10-19";

  src = fetchFromGitHub {
    owner = "xi-frontend";
    repo = "xi-term";
    rev = "5f44e9df154bf76bb65d9c2e8db7cc4caf376a58";
    sha256 = "0if7n5pnd7n9bp9gh22ai8sx4xii1rm1l2v8f4acfj3kyjc1kg29";
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

