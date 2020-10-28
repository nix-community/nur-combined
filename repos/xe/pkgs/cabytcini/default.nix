{ pkgs ? import <nixpkgs> { } }:

with pkgs;

rustPlatform.buildRustPackage rec {
  name = "cabytcini-${version}";
  version = "0.3.0";

  src = fetchgit {
    url = "https://tulpa.dev/cadey/cabytcini";
    rev = "364efb280cf9905c18f6169057069af712d6e405";
    sha256 = "0i15ms52psq2icsjfg12lb1dcs219zd9k8539r84wlmm745kra83";
  };

  buildInputs = [ pkg-config xorg.libX11 openssl ];

  legacyCargoFetcher = true;
  cargoSha256 = "05694lfd870c5rp3fnv6n4b2z05p374ipfpgmjlkimmxw6rwlvma";

  meta = with lib; {
    description = "lo mi cabytcini cankyuijde";
    homepage = "https://tulpa.dev/cadey/cabytcini";
    license = licenses.mit;
    maintainers = [ maintainers.xe ];
  };
}
