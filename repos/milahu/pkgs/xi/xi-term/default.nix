{ lib, rustPlatform, fetchFromGitHub, wrapXiFrontendHook }:

rustPlatform.buildRustPackage rec {
  name = "xi-term-${version}";
  version = "2019-02-13";

  src = fetchFromGitHub {
    owner = "xi-frontend";
    repo = "xi-term";
    rev = "549308abdfe87245ac8bbc9a9fa74045efc719ed";
    sha256 = "17z5w30nk0pddwa2r1fbfld8bvywda34pmk625bgfl179ks598gx";
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

