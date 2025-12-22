import sys
from pathlib import Path

VERBOSE = False


def verbose_print(*args, **kwargs):
    if VERBOSE:
        print(*args, **kwargs)


not_usb_supplies: list[Path] = []
offline_supplies: list[Path] = []
online_supplies: list[tuple[Path, float]] = []

for child in sorted(Path("/sys/class/power_supply").iterdir()):
    verbose_print(f"checking {child}")
    uevent_path = child / "uevent"
    if not uevent_path.exists():
        print(f"??? {uevent_path} doesn't exist, skipping", file=sys.stderr)
        continue
    attrs = {}
    for line in uevent_path.read_text().split("\n"):
        if line == '':
            continue
        k, v = line.split("=", 1)
        assert k not in attrs
        attrs[k] = v

    if "POWER_SUPPLY_TYPE" not in attrs:
        print(f"warn: {uevent_path} has no POWER_SUPPLY_TYPE, skipping", file=sys.stderr)
        continue

    if attrs["POWER_SUPPLY_TYPE"] != "USB":
        not_usb_supplies.append(child)
        continue

    if attrs["POWER_SUPPLY_ONLINE"] != "1":
        offline_supplies.append(child)
        continue

    # see https://docs.kernel.org/power/power_supply_class.html#units
    microvolts_now = int(attrs["POWER_SUPPLY_VOLTAGE_NOW"])
    microamps_now = int(attrs["POWER_SUPPLY_CURRENT_NOW"])
    volts_now = microvolts_now / 1000000
    amps_now = microamps_now / 1000000
    watts_now = volts_now * amps_now
    online_supplies.append((child, watts_now))

print("not usb")
for path in not_usb_supplies:
    print(f"  {path}")
print()
print("not online")
for path in offline_supplies:
    print(f"  {path}")
print()
for (path, watts) in online_supplies:
    print(f"{path}")
    print(f"  charging at {watts} watts")
