{ lib, rustPlatform, fetchFromGitHub, wrapXiFrontendHook }:

rustPlatform.buildRustPackage rec {
  name = "xi-term-${version}";
  version = "2018-10-20";

  src = fetchFromGitHub {
    owner = "xi-frontend";
    repo = "xi-term";
    rev = "80e4b7279d68f6a11ce7ffd25ae67a0f81a68fac";
    sha256 = "01m56hk8x3mshhlyw9gv3syy7nchc93mwjgga205zqjry0dkb4bi";
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

