# Basically a reimplementation in nix of https://github.com/adi1090x/rofi/blob/master/power/powermenu.sh

{
  stdenv, fetchFromGitHub, rofi-unwrapped-git, source-rofi, writeScript,
  coreutils, gawk, systemd, i3,
  theme ? "full_circle",
  colorscheme ? "nightly",
}:

# TODO: remove impurity on fonts

# Check if theme exists
assert builtins.elem theme [
  "full"
  "full_circle"
  "full_rounded"
  "full_alt"
  "card"
  "card_circle"
  "column"
  "column_circle"
  "row"
  "row_alt"
  "row_circle"
  "single"
  "single_circle"
  "single_full"
  "single_full_circle"
  "single_rounded"
  "single_text"
];

# Check if colorscheme exists
assert builtins.elem colorscheme [
  "bluish"
  "berry"
  "nordic"
  "nightly"
  "gotham"
  "mask"
  "faded"
  "cocoa"
];

let
  repo = stdenv.mkDerivation {
    name = "source-rofi-adi1090x";
    src = "${source-rofi}";

    patchPhase = ''
      rm power/styles/colors.rasi
      echo '@import "${colorscheme}.rasi"' > power/styles/colors.rasi
    '';
    installPhase = ''
      mkdir $out
      # Only copy power directory because we don't use the rest
      cp -r power $out
    '';
  };
  rofi = "${rofi-unwrapped-git}/bin/rofi";
  systemctl = "${systemd}/bin/systemctl";
in writeScript "powermenu" ''
  unset PATH

  shutdown=""
  reboot=""
  lock=""
  suspend=""
  logout=""

  options="$shutdown\n$reboot\n$lock\n$suspend\n$logout"
  uptime=$(${coreutils}/bin/uptime | ${gawk}/bin/awk '{ print $3 " " $4 }')

  chosen=$(echo -e "$options" | ${rofi} -theme ${repo}/power/${theme}.rasi -p "Uptime: $uptime" -dmenu -selected-row 2)

  confirm() {
	ans=$(${rofi} -dmenu -i -no-fixed-num-lines -p "Are you sure? : " -theme ${repo}/power/confirm.rasi)
	if [[ $ans == "yes" ]] || [[ $ans == "YES" ]] || [[ $ans == "y" ]]; then
		exec $@
	elif [[ $ans == "no" ]] || [[ $ans == "NO" ]] || [[ $ans == "n" ]]; then
		exit
        else
		${rofi} -theme "${repo}/power/message.rasi" -e "Available Options  -  yes / y / no / n"
        fi
  }

  case $chosen in
	$shutdown)
		confirm ${systemctl} poweroff
		;;
	$reboot)
		confirm ${systemctl} reboot
		;;
	$lock)
		echo "Definitely locking..."
		;;
	$suspend)
		confirm ${systemctl} suspend
		;;
	$logout)
		confirm ${i3}/bin/i3-msg exit
		;;
  esac
''

