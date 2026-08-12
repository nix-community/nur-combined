#!/usr/bin/env python3

import serial
import argparse
import os
import time

if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Activate RNDIS or CDC/ECM mode of dpt-rp1."
    )
    parser.add_argument(
        "-m",
        "--mode",
        type=str,
        default="RNDIS",
        help="mode to enable, can be RNDIS or CDC/ECM.",
    )
    parser.add_argument(
        "-d",
        "--device",
        type=str,
        default="/dev/ttyACM0",
        help="device to acitvate, default = /dev/ttyACM0.",
    )
    parser.add_argument("-t", "--timeout", type=int, default=10)
    args = parser.parse_args()

    modes = {
        "RNDIS": b"\x01\x00\x00\x01\x00\x00\x00\x01\x00\x04",
        "CDC/ECM": b"\x01\x00\x00\x01\x00\x00\x00\x01\x01\x04",
    }
    if args.mode not in modes:
        print(f"invalid mode: {args.mode}.")
        exit(1)
    print(f"sending {modes[args.mode]} to {args.device}...")
    with serial.Serial(args.device, timeout=args.timeout) as ser:
        ser.write(modes[args.mode])
    print("sent.")
    print("sleep for 5 seconds...")
    time.sleep(5)
    print("do avahi-resolve.")
    os.execv(
        "/usr/bin/env",
        ["/usr/bin/env", "avahi-resolve", "-n", "digitalpaper.local", "--verbose"],
    )
