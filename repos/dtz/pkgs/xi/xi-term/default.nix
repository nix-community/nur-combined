{ lib, rustPlatform, fetchFromGitHub, wrapXiFrontendHook }:

rustPlatform.buildRustPackage rec {
  name = "xi-term-${version}";
  version = "2019-01-19";

  src = fetchFromGitHub {
    owner = "xi-frontend";
    repo = "xi-term";
    rev = "68a15bd6bd13aa07d58ab8e977ce83fada6c8582";
    sha256 = "0yylf93jzgvxyamdf2a89dljgqzkq61hfrbgpr9xrakvzcm6rsgr";
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

