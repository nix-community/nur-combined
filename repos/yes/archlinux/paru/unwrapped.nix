{ lib
, rustPlatform
, fetchzip
, gettext
, installShellFiles
, openssl
, pacman
, pkg-config
, rp ? ""
}:

rustPlatform.buildRustPackage rec {
  pname = "paru-unwrapped";
  version = "1.11.1";

  src = fetchzip {
    url = "${rp}https://github.com/Morganamilo/paru/archive/refs/tags/v${version}.zip";
    hash = "sha256-Lnyjmli3vO1utp6LtDa3VsmXL4UE37ahOmpwwcpSeWM=";
  };

  cargoHash = "sha256-Tf0gk36k/ECgMZkXtfW6npsSX2IslG9Qz3vxqwyGIWY=";

  cargoUpdateHook = ''
    cat >> $CARGO_CONFIG <<EOF
    [source.crates-io]
    replace-with = "rp"
    [source.rp]
    registry = "${rp}https://github.com/rust-lang/crates.io-index"
    EOF
  '';

  postPatch = ''
    substituteInPlace src/lib.rs --replace "/usr/share" "$out/share"
  '';

  nativeBuildInputs = [ gettext installShellFiles pkg-config ];

  buildInputs = [ openssl pacman ];

  postInstall = ''
    mkdir -p $out/etc $out/share
    cp paru.conf $out/etc/paru.conf
    
    installManPage man/*

    installShellCompletion --bash --name paru.bash completions/bash
    installShellCompletion --fish --name paru.fish completions/fish
    installShellCompletion --zsh --name _paru completions/zsh

    ./scripts/mkmo locale
    cp -r locale $out/share
  '';

  meta = with lib; {
    description = "Feature packed AUR helper (without runtime depends wrapped)";
    homepage = "https://github.com/Morganamilo/paru";
    license = licenses.gpl3Only;
  };
}