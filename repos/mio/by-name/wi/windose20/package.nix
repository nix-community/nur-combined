{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  fetchurl,
  unzip,
  imagemagick,
  plymouth,
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

  nativeBuildInputs = [
    unzip
    imagemagick
  ];

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

    themeDir="$out/share/plymouth/themes/windose20"
    imagesDir="$themeDir/images"
    mkdir -p "$imagesDir"
    magick "$src/pngs/logo_with_name.png" -resize 480x -background none \
      "$imagesDir/logo.png"
    for i in $(seq -f "%02g" 0 79); do
      cp "$imagesDir/logo.png" "$imagesDir/animation-$i.png"
    done
    for asset in bullet.png capslock.png entry.png keyboard.png keymap-render.png lock.png; do
      cp "${plymouth}/share/plymouth/themes/spinner/$asset" "$imagesDir/"
    done
    cp ${./windose20.plymouth} "$themeDir/windose20.plymouth"
    substituteInPlace "$themeDir/windose20.plymouth" \
      --replace-fail '@IMAGES@' "$imagesDir/"

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
