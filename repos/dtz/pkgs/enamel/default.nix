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
  version = "2019-09-09";

  src = fetchFromGitHub {
    owner = "vhdirk";
    repo = "enamel";
    rev = "11f500f98e57e4d0a7248146138676c2941b20a3";
    sha256 = "09h1wq346r9fyx984g45hfaz4bnwa41yam718v3dm8wxaig3cvws";
  };

  buildInputs = [ sassc glib gtk3 notmuch libsoup gmime3 webkitgtk capnproto ];

  cargoSha256 = "0j97p3nd8chqs7w8068kgii2skjid7690r03gd3bx1l3v81ynqwz";

  cargoPatches = [ ./deps.patch ./cargo-lock.patch ];
  # cargoBuildFlags = [ "-p" "enamel-tui" ];

  # doCheck = false;

  meta = with lib; {
    maintainers = with maintainers; [ dtzWill ];
    license = licenses.gpl3;
  };
}

