{ writeShellApplication }:

writeShellApplication {
  name = "on-mains-power";
  text = ''
    for supply in '/sys/class/power_supply/'*; do
      if [[ "$(<"$supply/type")" == 'Mains' && "$(<"$supply/online")" == '1' ]]; then
        exit 0
      fi
    done

    exit 1
  '';
}
