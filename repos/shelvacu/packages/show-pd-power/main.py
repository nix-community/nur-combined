import sys
from pathlib import Path


for path in sorted(Path("/sys/class/power_supply").iterdir()):
    print(f"{path}")
    uevent_path = path / "uevent"
    if not uevent_path.exists():
        print(f"??? {uevent_path} doesn't exist, skipping", file=sys.stderr)
        continue
    attrs: dict[str, str] = {}
    for line in uevent_path.read_text().split("\n"):
        if line == "":
            continue
        k, v = line.split("=", 1)
        if k in attrs and attrs[k] != v:
            print(f"warn: {uevent_path} has duplicate key {k!r}={attrs[k]!r}, {k!r}={v!r}")
        attrs[k] = v

    if "POWER_SUPPLY_TYPE" not in attrs:
        print(
            f"warn: {uevent_path} has no POWER_SUPPLY_TYPE, skipping", file=sys.stderr
        )
        continue

    online = attrs.get("POWER_SUPPLY_ONLINE") == "1"

    if online:
        online_text = " ON"
    else:
        online_text = "OFF"

    infos: list[str] = [
        online_text,
        attrs["POWER_SUPPLY_TYPE"],
    ]

    if "POWER_SUPPLY_CAPACITY" in attrs:
        infos.append(f"{attrs["POWER_SUPPLY_CAPACITY"]}%")

    if "POWER_SUPPLY_VOLTAGE_NOW" in attrs and "POWER_SUPPLY_CURRENT_NOW" in attrs:
        # see https://docs.kernel.org/power/power_supply_class.html#units
        microvolts_now = int(attrs["POWER_SUPPLY_VOLTAGE_NOW"])
        microamps_now = int(attrs["POWER_SUPPLY_CURRENT_NOW"])
        volts_now = microvolts_now / 1000000
        amps_now = microamps_now / 1000000
        watts_now = volts_now * amps_now
        infos.append(f"{watts_now:.2f} watts")

    print(f"  {' - '.join(infos)}")
    print()
