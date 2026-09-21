{
  lib,
  rustPlatform,
  fetchFromGitHub,
  makeWrapper,
  nix,
  systemd,
  coreutils,
}:
rustPlatform.buildRustPackage rec {
  pname = "nix-reaper";
  version = "54a980d";

  src = fetchFromGitHub {
    owner = "ibuysausage";
    repo = "nix-reaper";
    rev = "${version}";
    sha256 = "sha256-6fd96IIWL3lRSoOKMy52G40Zm+qm3oZHUhlvwGuBI8M=";
  };

  cargoLock.lockFile = ./Cargo.lock;

  nativeBuildInputs = [ makeWrapper ];

  postInstall = ''
    wrapProgram $out/bin/nix-reaper \
      --prefix PATH : ${
        lib.makeBinPath [
          nix
          systemd
          coreutils
        ]
      }
  '';

  meta = with lib; {
    description = "Deep-clean a NixOS system: generations, boot entries, GC roots, and non-Nix bloat";
    homepage = "https://github.com/ibuysausage/nix-reaper";
    license = licenses.mit;
    mainProgram = "nix-reaper";
    platforms = platforms.linux;
  };
}
