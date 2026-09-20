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
  version = "43224d4";

  src = fetchFromGitHub {
    owner = "ibuysausage";
    repo = "nix-reaper";
    rev = "${version}";
    sha256 = "sha256-wCem4O5U9H6puSwQUb1bKEaiFM/xK/Ar8nT6uHKsPd4=";
  };

  cargoLock.lockFile = ./Cargo.lock;

  nativeBuildInputs = [makeWrapper];

  postInstall = ''
    wrapProgram $out/bin/nix-reaper \
      --prefix PATH : ${lib.makeBinPath [nix systemd coreutils]}
  '';

  meta = with lib; {
    description = "Deep-clean a NixOS system: generations, boot entries, GC roots, and non-Nix bloat";
    homepage = "https://github.com/ibuysausage/nix-reaper";
    license = licenses.mit;
    mainProgram = "nix-reaper";
    platforms = platforms.linux;
  };
}
