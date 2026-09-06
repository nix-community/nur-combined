power_supply_root=${POWER_SUPPLY_ROOT:-/sys/class/power_supply}
battery=

for candidate in "$power_supply_root"/*; do
  [[ -r $candidate/type && -r $candidate/capacity && -r $candidate/status ]] || continue

  read -r type <"$candidate/type"
  [[ $type == "Battery" ]] || continue

  if [[ -r $candidate/scope ]]; then
    read -r scope <"$candidate/scope"
    [[ $scope == "System" ]] || continue
  fi

  battery=$candidate
  break
done

# Desktops may expose mice and other peripherals as Device-scoped batteries.
[[ -n $battery ]] || exit 0

read -r pct <"$battery/capacity"
read -r state <"$battery/status"

if [[ ! $pct =~ ^[0-9]+$ ]]; then
  printf 'Unexpected battery capacity: %s\n' "$pct" >&2
  exit 1
fi

dis_icons=(󰁺 󰁻 󰁼 󰁽 󰁾 󰁿 󰂀 󰂁 󰂂 󰁹)
chg_icons=(󰢜 󰂆 󰂇 󰂈 󰢝 󰂉 󰢞 󰂊 󰂋 󰂅)

# bucket index = pct/10, max 9
idx=$((pct / 10))
((idx > 9)) && idx=9

case "$state" in
Charging) icon=${chg_icons[idx]} ;;
Full) icon=${dis_icons[9]} ;;
*) icon=${dis_icons[idx]} ;;
esac

dunstify -a osd -u low "${icon} Battery: ${pct}% (${state})"
