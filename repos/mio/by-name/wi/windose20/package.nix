{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  fetchurl,
  unzip,
  imagemagick,
  plymouth,
  plasma-overdose-kde-theme,
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

    splashDir="${plasma-overdose-kde-theme}/share/plasma/look-and-feel/Plasma-Overdose/contents/splash/images"
    # Match the NGO KSplash sequence: BIOS "booting" + progressive dots, then Windose welcome.
    # Keep frames modest so initrd stays reasonable; plymouth centers them on a black field.
    frameW=1280
    frameH=720
    magick "$splashDir/booting.png" -resize "''${frameW}x''${frameH}!" "$imagesDir/boot-base.png"
    magick "$splashDir/welcome.png" -resize "''${frameW}x''${frameH}!" "$imagesDir/welcome-base.png"
    # Upstream dots.jpg is a grey glyph on black. Punch out the black so we don't
    # paint a grey tile (brightness lifts used to turn that backdrop into a box).
    magick "$splashDir/dots.jpg" -alpha set \
      \( +clone -colorspace gray -threshold 8% \) \
      -compose CopyOpacity -composite \
      -resize 11x14 PNG32:"$imagesDir/dot.png"

    # Dot row placement mirrors Splash.qml (690/1920 x, 28/1080 from bottom).
    dotX0=$((690 * frameW / 1920))
    dotY=$((frameH - (28 * frameH / 1080) - 14))
    dotStep=11

    # progress-*/throbber-*: boot activity (BIOS screen, dots lighting up)
    for i in $(seq 0 39); do
      idx=$(printf '%02d' "$i")
      cmd=(magick "$imagesDir/boot-base.png")
      n=$((i + 1))
      for ((d = 0; d < n; d++)); do
        x=$((dotX0 + d * dotStep))
        cmd+=("$imagesDir/dot.png" -geometry "+''${x}+''${dotY}" -composite)
      done
      cmd+=("$imagesDir/progress-$idx.png")
      "''${cmd[@]}"
      # Compat name some two-step builds still probe during boot.
      ln "$imagesDir/progress-$idx.png" "$imagesDir/throbber-$idx.png"
    done

    # animation-*: end sequence — hold full dots, then fade to Windose welcome
    cp "$imagesDir/progress-39.png" "$imagesDir/animation-00.png"
    for i in $(seq 1 19); do
      idx=$(printf '%02d' "$i")
      pct=$((i * 100 / 19))
      magick "$imagesDir/progress-39.png" "$imagesDir/welcome-base.png" \
        -alpha on -compose blend -define "compose:args=''${pct}" -composite \
        "$imagesDir/animation-$idx.png"
    done
    cp "$imagesDir/welcome-base.png" "$imagesDir/animation-20.png"
    for i in $(seq 21 39); do
      idx=$(printf '%02d' "$i")
      ln "$imagesDir/animation-20.png" "$imagesDir/animation-$idx.png"
    done

    # Password / message dialogs still need a compact logo watermark.
    magick "$src/pngs/logo_with_name.png" -resize 480x -background none \
      "$imagesDir/logo.png"

    for asset in bullet.png capslock.png entry.png keyboard.png keymap-render.png lock.png; do
      cp "${plymouth}/share/plymouth/themes/spinner/$asset" "$imagesDir/"
    done
    rm -f "$imagesDir/boot-base.png" "$imagesDir/welcome-base.png" "$imagesDir/dot.png"

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
