{ pkgs, lib, fetchFromGitHub, makeRustPlatform, sassc, glib, gtk3, notmuch, libsoup, gmime3, webkitgtk }:

# :(
let
  nur-combined-src = fetchFromGitHub {
    owner = "nix-community";
    repo = "nur-combined";
    # commit from: 2018-12-23
    rev = "ba89a7a9a4a6cf4e1a9fd193ff577380d6fa3a86";
    sha256 = "1b0yng19vshpzqqzqdh1ffcvawyb4pyjmmwwclmx99si2xzb148s";
  };
  nur-combined = import "${nur-combined-src}" { inherit pkgs; };
  rust-nightly = nur-combined.repos.mozilla.latest.rustChannels.nightly.rust;
  rustPlatform = makeRustPlatform {
    cargo = rust-nightly;
    rustc = rust-nightly;
  };
in rustPlatform.buildRustPackage rec {
  name = "enamel-${version}";
  version = "2018-12-30";

  src = fetchFromGitHub {
    owner = "vhdirk";
    repo = "enamel";
    rev = "d09cd74cad2f3136bb1e31d9fde354eaf6cce76c";
    sha256 = "01qz2c0x0zm4cp4rm8w8h605j62zsmzr0fqwkdyaw0w2xl91n4ia";
  };

  buildInputs = [ sassc glib gtk3 notmuch libsoup gmime3 webkitgtk ];

  cargoSha256 = "1111111111111111111111111111111111111111111111111111";

  cargoPatches = [ ./deps.patch ./cargo-lock.patch ];
  # cargoBuildFlags = [ "-p" "enamel-tui" ];

  # doCheck = false;

  meta = with lib; {
    maintainers = with maintainers; [ dtzWill ];
    license = licenses.gpl3;
    broken = true;
  };
}

