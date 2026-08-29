{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  fetchurl,
  unzip,
}:

let
  fontVersion = "2026.02.27";
in
stdenvNoCC.mkDerivation {
  pname = "windose20";
  version = "0-unstable-2026-03-29";

  src = fetchFromGitHub {
    owner = "ArThirtyFour";
    repo = "windose20";
    rev = "d0a51fad532e1a63012210817fabc063de4f65b3";
    hash = "sha256-B272o5LcrE9yCK4c36gjVwW5utg/XVJpPEMVjeilSD0=";
  };

  nativeBuildInputs = [ unzip ];

  font = fetchurl {
    url = "https://github.com/TakWolf/fusion-pixel-font/releases/download/${fontVersion}/fusion-pixel-font-10px-proportional-ttf-v${fontVersion}.zip";
    hash = "sha256-PnWoHjM+NzX/8IwnXwDw+g3W9TX6gKCbAVvP6PsfegY=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/share/windose20/pngs"
    cp -r "$src/pngs/"* "$out/share/windose20/pngs/"

    mkdir -p "$out/share/windose20/configs"
    cp "$src/configs/config.conf" "$out/share/windose20/configs/neofetch.conf"
    cp "$src/configs/config.jsonc" "$out/share/windose20/configs/fastfetch.jsonc"
    cp "$src/configs/config" "$out/share/windose20/configs/cava.conf"

    substituteInPlace "$out/share/windose20/configs/neofetch.conf" \
      --replace-fail 'image_source="/home/kangel/Рабочий стол/windose20/ame_neofetch1.png"' \
      "image_source=\"$out/share/windose20/pngs/logo.png\""

    mkdir -p "$out/share/fonts/truetype"
    unzip -jo "$font" "fusion-pixel-10px-proportional-latin.ttf" -d "$out/share/fonts/truetype"

    runHook postInstall
  '';

  meta = {
    description = "Windose20 branding assets and configs for the Needy Girl Overdose KDE rice";
    homepage = "https://github.com/ArThirtyFour/windose20";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
  };
}
