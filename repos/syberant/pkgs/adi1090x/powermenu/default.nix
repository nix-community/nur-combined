# Basically a reimplementation in nix of https://github.com/adi1090x/rofi/blob/master/power/powermenu.sh

{
  fetchFromGitHub, rofi-unwrapped-git, writeScript,
  coreutils, gawk, systemd, i3
}:

# TODO: remove impurity on fonts

let
  repo = fetchFromGitHub {
	owner = "adi1090x";
	repo = "rofi";
	rev = "3fdc3f352f4bf31503cd1a10f188a97009e8d31a";
	sha256 = "0cnh7szwkj1rjva7yms8m5p08amhfb3i74vqcv44ais6szdq0nlr";
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

  chosen=$(echo -e "$options" | ${rofi} -theme ${repo}/power/full_circle.rasi -p "Uptime: $uptime" -dmenu -selected-row 2)

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

