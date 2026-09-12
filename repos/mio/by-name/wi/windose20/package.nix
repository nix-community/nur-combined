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

  fontMono = fetchurl {
    url = "https://github.com/TakWolf/fusion-pixel-font/releases/download/${fontVersion}/fusion-pixel-font-10px-monospaced-ttf-v${fontVersion}.zip";
    hash = "sha256-QZAwMDKYfbp8H9/NZYbyzhkWK/ruuYsmRgVvQGa2axI=";
  };

  # Desktop wallpaper from the rice README (missing from ArThirtyFour fork we package).
  wallpaper = fetchurl {
    url = "https://raw.githubusercontent.com/Ar4ikTrirtyFour/windose20/main/pngs/bg.png";
    hash = "sha256-OJyOQAh6S+UoHI7J3ZfavYHu0zMk9VrFphxyXP1DGEw=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/share/windose20/pngs"
    cp -r "$src/pngs/"* "$out/share/windose20/pngs/"
    cp "$wallpaper" "$out/share/windose20/pngs/bg.png"

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

    mkdir -p "$out/share/fonts/truetype"
    # Prop for UI; Mono for terminals (kgx/Konsole). Family names are
    # "Fusion Pixel 10px Prop latin" / "Fusion Pixel 10px Mono latin".
    unzip -jo "$font" "fusion-pixel-10px-proportional-latin.ttf" -d "$out/share/fonts/truetype"
    unzip -jo "$fontMono" "fusion-pixel-10px-monospaced-latin.ttf" -d "$out/share/fonts/truetype"
    fontProp="$out/share/fonts/truetype/fusion-pixel-10px-proportional-latin.ttf"

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

    # progress-*: boot activity (BIOS screen, dots lighting up)
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
    done

    # startup-animation-* / animation-*: boot end sequence — hold full dots, then fade to Windose welcome
    cp "$imagesDir/progress-39.png" "$imagesDir/animation-00.png"
    ln "$imagesDir/animation-00.png" "$imagesDir/startup-animation-00.png"
    for i in $(seq 1 19); do
      idx=$(printf '%02d' "$i")
      pct=$((i * 100 / 19))
      magick "$imagesDir/progress-39.png" "$imagesDir/welcome-base.png" \
        -alpha on -compose blend -define "compose:args=''${pct}" -composite \
        "$imagesDir/animation-$idx.png"
      ln "$imagesDir/animation-$idx.png" "$imagesDir/startup-animation-$idx.png"
    done
    cp "$imagesDir/welcome-base.png" "$imagesDir/animation-20.png"
    ln "$imagesDir/animation-20.png" "$imagesDir/startup-animation-20.png"
    for i in $(seq 21 39); do
      idx=$(printf '%02d' "$i")
      ln "$imagesDir/animation-20.png" "$imagesDir/animation-$idx.png"
      ln "$imagesDir/animation-20.png" "$imagesDir/startup-animation-$idx.png"
    done

    # shutdown-animation-*: dedicated retro shutdown sequence for Needy Girl Overdose
    # Phase 1 (frames 0..19): Windose20 shutting down with animated dots
    # Phase 2 (frames 20..39): Needy Girl Overdose retro safe-to-turn-off farewell screen
    magick "$src/pngs/logo_with_name.png" -resize 420x "$imagesDir/shutdown-logo.png"

    magick -size "''${frameW}x''${frameH}" xc:black \
      "$imagesDir/shutdown-logo.png" -gravity center -geometry +0-70 -composite \
      -font "$fontProp" \
      -pointsize 26 -fill '#FF70A6' -gravity center -annotate +0+130 "Windose20 is shutting down." \
      -pointsize 18 -fill '#A0A0A0' -gravity center -annotate +0+175 "Please wait while your computer turns off." \
      "$imagesDir/shut-p1-0.png"

    magick -size "''${frameW}x''${frameH}" xc:black \
      "$imagesDir/shutdown-logo.png" -gravity center -geometry +0-70 -composite \
      -font "$fontProp" \
      -pointsize 26 -fill '#FF70A6' -gravity center -annotate +0+130 "Windose20 is shutting down.." \
      -pointsize 18 -fill '#A0A0A0' -gravity center -annotate +0+175 "Please wait while your computer turns off." \
      "$imagesDir/shut-p1-1.png"

    magick -size "''${frameW}x''${frameH}" xc:black \
      "$imagesDir/shutdown-logo.png" -gravity center -geometry +0-70 -composite \
      -font "$fontProp" \
      -pointsize 26 -fill '#FF70A6' -gravity center -annotate +0+130 "Windose20 is shutting down..." \
      -pointsize 18 -fill '#A0A0A0' -gravity center -annotate +0+175 "Please wait while your computer turns off." \
      "$imagesDir/shut-p1-2.png"

    magick -size "''${frameW}x''${frameH}" xc:black \
      "$imagesDir/shutdown-logo.png" -gravity center -geometry +0-70 -composite \
      -font "$fontProp" \
      -pointsize 26 -fill '#FF70A6' -gravity center -annotate +0+130 "Windose20 is shutting down...." \
      -pointsize 18 -fill '#A0A0A0' -gravity center -annotate +0+175 "Please wait while your computer turns off." \
      "$imagesDir/shut-p1-3.png"

    magick -size "''${frameW}x''${frameH}" xc:black \
      "$imagesDir/shutdown-logo.png" -gravity center -geometry +0-70 -composite \
      -font "$fontProp" \
      -pointsize 26 -fill '#FF70A6' -gravity center -annotate +0+125 "† Ame has logged off †" \
      -pointsize 22 -fill '#FFA500' -gravity center -annotate +0+170 "It is now safe to turn off your computer." \
      -pointsize 18 -fill '#888888' -gravity center -annotate +0+210 "† BLESS †" \
      "$imagesDir/shut-safe.png"

    for i in $(seq 0 4); do
      idx=$(printf '%02d' "$i")
      ln "$imagesDir/shut-p1-0.png" "$imagesDir/shutdown-animation-$idx.png"
    done
    for i in $(seq 5 9); do
      idx=$(printf '%02d' "$i")
      ln "$imagesDir/shut-p1-1.png" "$imagesDir/shutdown-animation-$idx.png"
    done
    for i in $(seq 10 14); do
      idx=$(printf '%02d' "$i")
      ln "$imagesDir/shut-p1-2.png" "$imagesDir/shutdown-animation-$idx.png"
    done
    for i in $(seq 15 19); do
      idx=$(printf '%02d' "$i")
      ln "$imagesDir/shut-p1-3.png" "$imagesDir/shutdown-animation-$idx.png"
    done

    for i in $(seq 20 24); do
      idx=$(printf '%02d' "$i")
      pct=$(((i - 19) * 100 / 5))
      magick "$imagesDir/shut-p1-3.png" "$imagesDir/shut-safe.png" \
        -alpha on -compose blend -define "compose:args=''${pct}" -composite \
        "$imagesDir/shutdown-animation-$idx.png"
    done

    for i in $(seq 25 39); do
      idx=$(printf '%02d' "$i")
      ln "$imagesDir/shut-safe.png" "$imagesDir/shutdown-animation-$idx.png"
    done

    rm -f "$imagesDir/shut-p1-0.png" "$imagesDir/shut-p1-1.png" "$imagesDir/shut-p1-2.png" \
          "$imagesDir/shut-p1-3.png" "$imagesDir/shut-safe.png" "$imagesDir/shutdown-logo.png"

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

    runHook postInstall
  '';

  meta = {
    description = "Windose20 branding assets and configs for the Needy Girl Overdose KDE rice";
    homepage = "https://github.com/ArThirtyFour/windose20";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
  };
}
