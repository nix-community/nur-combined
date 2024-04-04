
import sys

s = 0
for line in sys.stdin:
    (val, unit) = line.split(" ")
    val = float(val)

    if "MiB" in unit:
        val *= 1000

    s += val

print("MB: ", round(s/1000))
print("GB: ", round(s/1000000))


