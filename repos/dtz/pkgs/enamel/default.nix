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
  version = "2018-12-22";

  src = fetchFromGitHub {
    owner = "vhdirk";
    repo = "enamel";
    rev = "1bff1f498eb64ba173851cf75172c54be037939a";
    sha256 = "1qw1qymrnx1ac0qk95q84jq25h41a64whmfmxdv9yrxwfhs3fqnb";
  };

  buildInputs = [ sassc glib gtk3 notmuch libsoup gmime3 webkitgtk ];

  cargoPatches = [
    ./0001-Don-t-look-for-deps-locally-that-don-t-generally-exi.patch
    ./0002-Cargo.lock-init.patch
    ./0003-use-develop-branch-of-notmuch-rs.patch
    ./0004-Cargo.lock-bump.patch
  ];

  postPatch = ''
    substituteInPlace enamel-core/src/lib.rs \
      --replace '#![feature(custom_derive)]' ""
  '';

  cargoSha256 = "0vl8lf6iwxm9iad6qxanfmcj2a7kmg7pc6a8qrbbng8drssrgf2n";

  cargoBuildFlags = [ "-p" "enamel-tui" ];

  doCheck = false;

  meta = with lib; {
    maintainers = with maintainers; [ dtzWill ];
    license = licenses.gpl3;
    broken = true;
  };
}

