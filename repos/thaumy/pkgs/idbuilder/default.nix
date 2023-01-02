{ lib, pkgs, stdenv, fetchurl, runCommand, rustPlatform, makeDesktopItem
, fetchFromGitHub, yarn2nix-moretea }:

let
  overlay_pkgs = pkgs.extend (import ./rust-overlay);

  appBinName = "idbuilder";
  appVersion = "6.0.1";
  appComment = "More than an identifier building tool";

  desktopItem = makeDesktopItem rec {
    name = appBinName;

    desktopName = "IDBuilder";
    genericName = desktopName;
    comment = appComment;

    exec = name;
    icon = name;

    type = "Application";
  };

  src_ruster = fetchFromGitHub {
    owner = "Thaumy";
    repo = "ruster";
    rev = "b98c4bd8ae2867e7eaba6de090a5df09ef9397f5";
    sha256 = "03p6r0lviasd1c5cq1xvhhafhs5r9fgzym5mfi802y9rwx7xjmpv";
  };

  src_palaflake = fetchFromGitHub {
    owner = "Thaumy";
    repo = "palaflake";
    rev = "c8e76f1bc89a8dcd4a938cc1cd83a48897b688e0";
    sha256 = "0i82hijl4hmn4b47dl8xxzza9z7z5g7nfck99yqd5am0piwvz2gp";
  };

  src_idbuilder = fetchFromGitHub {
    owner = "Thaumy";
    repo = "palaflake";
    rev = "b04f62af765ea8c68f9874e947f25c9fdb64807c";
    sha256 = "0sy5qg1mbd3q39dfi3iswx2jd5vr6znvginj6474dylhwhbn1ksk";
  };

  node_modules = yarn2nix-moretea.mkYarnModules rec {
    pname = appBinName;
    version = appVersion;
    name = "${pname}_node_modules_${version}";

    # v1 lock file
    yarnLock = ./yarn.lock;
    # generated from v1 lock file by yarn2nix
    yarnNix = ./yarn.nix;

    packageJSON = "${src_idbuilder}/package.json";
  };

  inputs = with overlay_pkgs; [
    gtk3
    glib
    dbus
    cairo
    libsoup
    webkitgtk
    openssl_3
    gdk-pixbuf
    pkg-config
    appimagekit

    yarn
    rust-bin.nightly.latest.minimal
  ];

in rustPlatform.buildRustPackage {
  pname = appBinName;
  version = appVersion;

  # TODO: here could be simplified
  buildInputs = inputs;
  nativeBuildInputs = inputs;

  src = ./.;

  cargoLock.lockFile = ./Cargo.lock;

  # TODO: why it failed with 666 permission?
  buildPhase = ''
    cp -r ${src_idbuilder}/* .
    cp -r ${node_modules}/node_modules .
    yarn --offline build

    chmod -R 777 src-tauri

    mkdir -p deps/ruster
    cp -r ${src_ruster}/* deps/ruster
    cp -r ${src_palaflake}/* deps
    mv deps src-tauri

    cd src-tauri
    cargo build --release
  '';

  installPhase = ''
    cd ..

    # bin
    mkdir -p $out/bin
    cp src-tauri/target/release/${appBinName} $out/bin

    # icon & .desktop
    mkdir -p $out/share/icons
    cp public/tauri.svg $out/share/icons/${appBinName}.svg
    mkdir -p $out/share/applications
    ln -s ${desktopItem}/share/applications/* $out/share/applications

    # echo for debug
    echo -e "\nApp was successfully installed in $out\n"
  '';

  meta = {
    description = appComment;
    homepage = "https://github.com/Thaumy/idbuilder";
    license = lib.licenses.mit;
    maintainers = [ "thaumy" ];
    platforms = lib.platforms.linux;
  };
}
