{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  nix-update-script,
}:
stdenvNoCC.mkDerivation {
  pname = "alacritty-rose-pine";
  version = "0-unstable-2025-11-05";

  src = fetchFromGitHub {
    owner = "rose-pine";
    repo = "alacritty";
    rev = "a6f7c8245e5bba639befe52e1e025f84ba8b3ee5";
    hash = "sha256-eVQjH5TrMLP9FdxIovnH9ulxTr6uw82Dt8PGGvpF94k=";
  };

  buildCommand = ''
    mkdir $out
    cp $src/dist/*.toml $out/
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    description = "Soho vibes for Alacritty";
    homepage = "https://github.com/rose-pine/alacritty";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
}
