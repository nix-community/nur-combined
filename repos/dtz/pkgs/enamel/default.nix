{ pkgs, lib, fetchFromGitHub, makeRustPlatform, sassc, glib, gtk3, notmuch, libsoup, gmime3, webkitgtk, capnproto }:

# :(
let
  nur-combined-src = fetchFromGitHub {
    owner = "nix-community";
    repo = "nur-combined";
    # commit from: 2019-09-09
    rev = "9f362f57ba709041d4a7ea5b5ecc5e7ffcff078d";
    sha256 = "0vx50s0lpkhjd7hgrgi3hqddrfl1kj1f3070vyygrrm3gfyic539";
  };
  nur-combined = import "${nur-combined-src}" { inherit pkgs; };
  rust-nightly = nur-combined.repos.mozilla.latest.rustChannels.nightly.rust;
  rustPlatform = makeRustPlatform {
    cargo = rust-nightly;
    rustc = rust-nightly;
  };
in rustPlatform.buildRustPackage rec {
  name = "enamel-${version}";
  version = "2019-09-17";

  src = fetchFromGitHub {
    owner = "vhdirk";
    repo = "enamel";
    rev = "6be0185fcee9d89b878a3434e2bbc7db982ab112";
    sha256 = "1nq13lyq59rq0vchiqj8b8xlk5ac2w0cn6drpcgj80kqbaq6g440";
  };

  buildInputs = [ sassc glib gtk3 notmuch libsoup gmime3 webkitgtk capnproto ];

  cargoSha256 = "1y9l31mncm9m99msfj55wxglprp7y74dlpbfw2nixkn69gfm3rpn";

  cargoPatches = [ ./cargo-lock.patch ./no-test.patch ];
  # cargoBuildFlags = [ "-p" "enamel-tui" ];

  # doCheck = false;

  meta = with lib; {
    maintainers = with maintainers; [ dtzWill ];
    license = licenses.gpl3;
  };
}

