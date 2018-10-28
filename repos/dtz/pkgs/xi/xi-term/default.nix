{ lib, rustPlatform, fetchFromGitHub, wrapXiFrontendHook }:

rustPlatform.buildRustPackage rec {
  name = "xi-term-${version}";
  version = "2018-10-27";

  src = fetchFromGitHub {
    owner = "xi-frontend";
    repo = "xi-term";
    rev = "3ec107a0b2da3bc8d87f4890a91a8fc18a91588a";
    sha256 = "1q57gkb5a3qy77b3lhr6z2lk5mz508m5dxv3jwi1aq1bdd64k4vj";
  };

  cargoSha256 = "0q7ikqdrc29nm0nwh9k5z88v57m472nri6xvx76sv71x0fmp12r0";

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

