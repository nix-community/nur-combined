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
  version = "f5cc8c4";

  src = fetchFromGitHub {
    owner = "ibuysausage";
    repo = "nix-reaper";
    rev = "${version}";
    sha256 = "sha256-sQG7dIGzyQhAyYlF93RzBicgLnbS2jnA/mJwkK4tPFY=";
  };

  cargoLock.lockFile = ./Cargo.lock;

  nativeBuildInputs = [makeWrapper];

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
