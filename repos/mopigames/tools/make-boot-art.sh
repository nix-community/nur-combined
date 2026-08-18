#!/usr/bin/env bash
# Generate the boot artwork from the logo.
#
#   tools/make-boot-art.sh [path/to/logo.png]
#
# Everything it produces is committed, so a normal build needs neither
# ImageMagick nor the source logo.  Re-run it only when the logo changes.
#
# The logo is 200x200 and square, which is a logo and not a background, so the
# screens are composed around it rather than stretched from it.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOGO="${1:-$HOME/Pictures/moonlight-os.png}"

[[ -f "$LOGO" ]] || { echo "no logo at $LOGO" >&2; exit 1; }
command -v magick >/dev/null || { echo "ImageMagick (magick) is required" >&2; exit 1; }

# Sampled from the logo itself.
BG='#14161A'
CRIMSON='#D60852'
GREY='#545A62'
WHITE='#F6E7ED'
FONT="$(fc-match -f '%{file}' 'DejaVu Sans:style=Bold')"

PLY="$HERE/config/includes.chroot/usr/share/plymouth/themes/moonlight-os"
SHARE="$HERE/config/includes.chroot/usr/share/moonlight-os"
mkdir -p "$PLY" "$SHARE" \
         "$HERE/config/bootloaders/isolinux" \
         "$HERE/config/bootloaders/grub-pc"

say() { printf '  %s\n' "$*"; }

# ImageMagick keeps whatever precision it was built with -- on a Q16 build,
# which is the usual one, that means every PNG written here comes out at 16
# bits per channel.  Plymouth does not care, but GRUB's PNG reader handles 8
# bits and nothing else: it rejects a 16-bit file outright, the theme's
# desktop-image fails to load, and the boot menu is then drawn as an empty
# frame with no entries in it.  Every magick call below therefore passes
# -depth 8, and the full-screen ones -alpha off as well since they are opaque
# backgrounds and the alpha channel is only weight.
D8=(-depth 8)

# ---------------------------------------------------------------- logo ------
say "logo"
magick "$LOGO" -resize 200x200 "${D8[@]}" "$SHARE/logo.png"

# ------------------------------------------------------------ plymouth ------
# 36 frames, a crimson arc travelling around a grey track outside the logo.
# The logo itself stays still: it has a swirl in it, and spinning that looks
# like a mistake rather than a loading indicator.
#
# They are throbber-*.png, not animation-*.png.  two-step treats the latter as
# a one-shot intro that plays once and leaves an empty screen behind; the
# throbber is the one that loops for as long as the boot takes.
say "plymouth frames"
rm -f "$PLY"/animation-*.png "$PLY"/throbber-*.png
magick "$LOGO" -resize 150x150 -background none -gravity center -extent 200x200 \
	"${D8[@]}" "$PLY/.logo-centred.png"

for i in $(seq 0 35); do
	angle=$((i * 10))
	magick -size 200x200 xc:none \
		-fill none \
		-stroke "$GREY"    -strokewidth 3 -draw "circle 100,100 100,10" \
		-stroke "$CRIMSON" -strokewidth 6 -draw "arc 10,10 190,190 $angle,$((angle + 100))" \
		"${D8[@]}" "$PLY/.ring.png"
	magick "$PLY/.logo-centred.png" "$PLY/.ring.png" -composite \
		"${D8[@]}" "$(printf '%s/throbber-%04d.png' "$PLY" $((i + 1)))"
done
rm -f "$PLY/.ring.png" "$PLY/.logo-centred.png"

# two-step will not start at all without these, and the failure is silent:
# plymouth just falls back to its own three dots on a grey background, with
# nothing in any log to say why.  They are only ever drawn for a password
# prompt, which this appliance never shows, but they have to exist.
say "plymouth ui assets"
magick -size 320x44 xc:none -fill '#1E2126' -stroke "$GREY" -strokewidth 2 \
	-draw "roundrectangle 1,1 318,42 6,6" "${D8[@]}" "$PLY/entry.png"
magick -size 12x12 xc:none -fill "$WHITE" -stroke none \
	-draw "circle 6,6 6,1" "${D8[@]}" "$PLY/bullet.png"
magick -size 32x40 xc:none \
	-fill none -stroke "$WHITE" -strokewidth 3 -draw "arc 9,6 23,26 180,360" \
	-fill "$WHITE" -stroke none -draw "roundrectangle 5,21 27,37 3,3" \
	"${D8[@]}" "$PLY/lock.png"
magick -size 28x18 xc:none -fill none -stroke "$GREY" -strokewidth 2 \
	-draw "roundrectangle 1,1 26,16 3,3" "${D8[@]}" "$PLY/keyboard.png"
magick -size 24x24 xc:none -fill "$WHITE" -stroke none \
	-draw "polygon 12,4 21,14 15,14 15,20 9,20 9,14 3,14" "${D8[@]}" "$PLY/capslock.png"
magick -size 16x16 xc:none "${D8[@]}" "$PLY/keymap-render.png"

cat > "$PLY/moonlight-os.plymouth" <<PLYMOUTH
[Plymouth Theme]
Name=Moonlight OS
Description=Moonlight OS boot splash
ModuleName=two-step

[two-step]
ImageDir=/usr/share/plymouth/themes/moonlight-os
HorizontalAlignment=.5
VerticalAlignment=.5
Transition=none
TransitionDuration=0.0
BackgroundStartColor=0x14161A
BackgroundEndColor=0x14161A
ProgressBarBackgroundColor=0x545A62
ProgressBarForegroundColor=0xD60852
Font=DejaVu Sans 12
TitleFont=DejaVu Sans 22
MessageBelowAnimation=true

[boot-up]
UseEndAnimation=false

[shutdown]
UseEndAnimation=false

[reboot]
UseEndAnimation=false
PLYMOUTH

# ------------------------------------------------------ boot menu screens ---
# Both bootloaders already look for a splash.png of their own; the sizes are
# what each one actually renders at, and the artwork stays clear of the rows
# the menu itself draws into.
#
#   isolinux: vesamenu at 640x480, "menu vshift 12" puts the menu at y=192
#   grub:     gfxmode 800x600, the theme puts the boot menu at 52% = y=312
menu_screen() {
	local out=$1 w=$2 h=$3 logo=$4 logo_y=$5 text_y=$6 pt=$7 rule_y=$8
	magick -size "${w}x${h}" "xc:$BG" \
		\( "$LOGO" -resize "${logo}x${logo}" \) \
			-gravity north -geometry "+0+${logo_y}" -composite \
		-font "$FONT" -pointsize "$pt" -fill "$WHITE" \
		-gravity north -annotate "+0+${text_y}" "MOONLIGHT OS" \
		-fill "$CRIMSON" -stroke none \
		-draw "rectangle $((w / 2 - 70)),${rule_y} $((w / 2 + 70)),$((rule_y + 2))" \
		"${D8[@]}" -alpha off \
		"$out"
}

say "isolinux splash 640x480"
menu_screen "$HERE/config/bootloaders/isolinux/splash.png" 640 480 108 18 138 22 174

say "grub splash 800x600"
menu_screen "$HERE/config/bootloaders/grub-pc/splash.png" 800 600 160 48 224 30 274

# The installed system's GRUB scales whatever GRUB_BACKGROUND points at, so
# this one is full size.
#
# The rule's coordinates are absolute -- -draw is not moved by the -gravity
# that -annotate above it uses -- and they have to be derived from where the
# text actually lands, which is the trap this walked into once already: the
# rule sat at y=600 while 54pt DejaVu Bold renders "MOONLIGHT OS" across rows
# 580-619, so it struck the wordmark straight through like a strikethrough.
#
# These match the proportions of the 800x600 menu screen, which is the one
# that looks right: the rule sits a gap of 1.3x the text height below the
# baseline, is 0.55x the text's width, and is as thick as 0.14x the text
# height. At 40px-tall text spanning columns 727-1192 that gives a 5px rule
# across 833-1087, starting 53px below row 619.
say "installed-system grub background 1920x1080"
magick -size 1920x1080 "xc:$BG" \
	\( "$LOGO" -resize 260x260 \) -gravity center -geometry "+0-140" -composite \
	-font "$FONT" -pointsize 54 -fill "$WHITE" \
	-gravity center -annotate "+0+60" "MOONLIGHT OS" \
	-fill "$CRIMSON" -stroke none -draw "rectangle 833,672 1087,676" \
	"${D8[@]}" -alpha off \
	"$SHARE/grub-background.png"



# ------------------------------------------------------------ ansi logo -----
# A coloured logo for fastfetch, drawn with half-blocks so each character cell
# carries two pixels: foreground is the top half, background the bottom.
# 24-bit escapes, which the Linux console degrades to its nearest colour
# rather than mangling, so it works on the bare tty as well as in a terminal.
say "fastfetch ansi logo"
magick "$LOGO" -resize 40x40\! -depth 8 txt:- | python3 -c '
import re, sys

px = {}
for line in sys.stdin:
    m = re.match(r"(\d+),(\d+): \(([^)]*)\)", line)
    if not m:
        continue
    x, y = int(m.group(1)), int(m.group(2))
    parts = [p.strip() for p in m.group(3).split(",")]
    vals = []
    for p in parts:
        vals.append(float(p[:-1]) * 255 / 100 if p.endswith("%") else float(p))
    r, g, b = (int(round(v)) for v in vals[:3])
    a = int(round(vals[3])) if len(vals) > 3 else 255
    px[(x, y)] = (r, g, b, a)

w = max(k[0] for k in px) + 1
h = max(k[1] for k in px) + 1
out = []
for y in range(0, h - h % 2, 2):
    row = ""
    for x in range(w):
        top = px.get((x, y), (0, 0, 0, 0))
        bot = px.get((x, y + 1), (0, 0, 0, 0))
        t_on, b_on = top[3] > 128, bot[3] > 128
        if not t_on and not b_on:
            row += "\x1b[0m "
        elif t_on and b_on:
            row += "\x1b[38;2;%d;%d;%dm\x1b[48;2;%d;%d;%dm▀" % (top[:3] + bot[:3])
        elif t_on:
            row += "\x1b[0m\x1b[38;2;%d;%d;%dm▀" % top[:3]
        else:
            row += "\x1b[0m\x1b[38;2;%d;%d;%dm▄" % bot[:3]
    out.append(row + "\x1b[0m")
sys.stdout.write("\n".join(out) + "\n")
' > "$SHARE/logo.ans"
say "  $(wc -l < "$SHARE/logo.ans") rows"

say "done"
