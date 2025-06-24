{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  nix-update-script,
}:
stdenvNoCC.mkDerivation {
  pname = "alacritty-rose-pine";
  version = "0-unstable-2023-07-13";

  src = fetchFromGitHub {
    owner = "rose-pine";
    repo = "alacritty";
    rev = "3c3e36eb5225b0eb6f1aa989f9d9e783a5b47a83";
    hash = "sha256-LU8H4e5bzCevaabDgVmbWoiVq7iJ4C1VfQrWGpRwLq0=";
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
