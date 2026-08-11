# TODO build nym-wallet from source
# this should be part of the nym build
# because "yarn build" depends on a nym build
# https://github.com/NixOS/nixpkgs/blob/master/pkgs/by-name/ny/nym/package.nix
/*
git clone --depth=1 https://github.com/nymtech/nym
cd nym
cd nym-wallet
yarn install
yarn build
*/

{
  lib,
  stdenv,
  fetchurl,
  appimage-run,
}:

stdenv.mkDerivation rec {
  pname = "nym-wallet-bin";
  version = "1.2.18";

  src = fetchurl {
    # https://github.com/nymtech/nym/releases
    url = "https://github.com/nymtech/nym/releases/download/nym-wallet-v1.2.18/NymWallet_1.2.18_amd64.AppImage";
    hash = "sha256-WCWty+PqctuAASK+SOVrmSdZXOeNCwmPesXv6tTy3Uc=";
  };

  dontUnpack = true;

  installPhase = ''
    mkdir -p $out/bin
    cat >$out/bin/nym-wallet <<EOF
    #!/bin/sh
    exec ${appimage-run}/bin/appimage-run ${src} "\$@"
    EOF
    chmod +x $out/bin/nym-wallet
  '';

  meta = {
    description = "The Nym desktop wallet enables you to use the Nym network and take advantage of its key capabilities";
    # https://nym.com/wallet
    homepage = "https://github.com/nymtech/nym/tree/develop/nym-wallet";
    # FIXME error: attribute 'rev' missing
    # changelog = "https://github.com/nymtech/nym/blob/${src.rev}/CHANGELOG.md";
    # https://github.com/nymtech/nym/blob/develop/nym-wallet/package.json
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "nym-wallet";
    platforms = lib.platforms.all;
  };
}
