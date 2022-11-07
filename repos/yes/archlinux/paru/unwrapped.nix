{ lib
, rustPlatform
, fetchFromGitHub
, gettext
, installShellFiles
, openssl
, pacman
, pkg-config
}:

rustPlatform.buildRustPackage rec {
  pname = "paru-unwrapped";
  version = "1.11.2";

  src = fetchFromGitHub {
    owner = "Morganamilo";
    repo = "paru";
    rev = "v${version}";
    hash = "sha256-9MzT4AIMeFaNLbtiatKcyVL83bsL3+nawwKl9WvOinY=";
  };

  cargoHash = "sha256-unhcIXCvw26GQpG7yX94mq2RPD5vLeJfDWxJhJ7ZRj0=";

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