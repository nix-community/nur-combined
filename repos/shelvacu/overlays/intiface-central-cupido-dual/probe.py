"""Probe which Cupido motor each B0 03 variant drives. Close Intiface first."""

import asyncio
import sys

from bleak import BleakClient, BleakScanner

NAME = "MY2607-BLE-V1.0"
TX = "0000f0b1-0000-1000-8000-00805f9b34fb"
RX = "0000f0b2-0000-1000-8000-00805f9b34fb"

# Only bytes 2-4 vary; the app always sends them as 0.
VARIANTS = [
    (0, 0, 0),
    (1, 0, 0),
    (0, 1, 0),
    (0, 0, 1),
    (1, 1, 0),
    (2, 0, 0),
    (0, 2, 0),
]


def on_notify(_, data: bytearray):
    print(f"  <- {data.hex(' ')}")


async def send(client, data):
    print(f"  -> {bytes(data).hex(' ')}")
    await client.write_gatt_char(TX, bytes(data), response=False)


async def main():
    print(f"scanning for {NAME}...")
    dev = await BleakScanner.find_device_by_name(NAME, timeout=20)
    if dev is None:
        sys.exit("not found")
    async with BleakClient(dev) as client:
        await client.start_notify(RX, on_notify)
        print("battery / pattern counts:")
        await send(client, [0xB0, 0x00])
        await send(client, [0xB0, 0x09])
        await asyncio.sleep(1)

        results = []
        for b2, b3, b4 in VARIANTS:
            input(f"\nvariant {b2} {b3} {b4}: press enter to run 3s")
            await send(client, [0xB0, 0x03, b2, b3, b4, 0xC0, 0xAA])
            await asyncio.sleep(3)
            await send(client, [0xB0, 0x03, b2, b3, b4, 0x00, 0xAA])
            await send(client, [0xB0, 0x02, 0, 0, 0, 0])
            await send(client, [0xB0, 0x01, 0, 0, 0, 0])
            ans = input("what ran? [t]apping/[v]ibration/[b]oth/[n]othing: ")
            results.append(((b2, b3, b4), ans.strip()))

        print("\nresults:")
        for v, ans in results:
            print(f"  B0 03 {v[0]:02x} {v[1]:02x} {v[2]:02x} <lvl> AA: {ans}")


asyncio.run(main())
