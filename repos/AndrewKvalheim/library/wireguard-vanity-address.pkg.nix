{ fetchCrate
, lib
, nix-update-script
, rustPlatform
, versionCheckHook
}:

let
  inherit (lib) licenses;
in
rustPlatform.buildRustPackage (wireguard-vanity-address: {
  pname = "wireguard-vanity-address";
  version = "0.4.0";
  meta = {
    description = "Find Wireguard VPN keypairs with a specific readable string";
    homepage = "https://github.com/warner/wireguard-vanity-address";
    license = licenses.mit;
  };

  passthru.updateScript = nix-update-script { };

  src = fetchCrate {
    inherit (wireguard-vanity-address) pname version;
    sha256 = "sha256-89Xj/hEzHqLQcv6ljALWwZaYOYTTVvXb9Jln1n/vXMM=";
  };

  # Workaround for NixOS/nixpkgs#392872
  cargoDeps = rustPlatform.importCargoLock {
    lockFile = ./assets/wireguard-vanity-address-Cargo.lock; # Copied from src
  };

  # versionCheckHook pending warner/wireguard-vanity-address#32
})
