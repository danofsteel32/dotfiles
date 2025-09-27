#!/usr/bin/python

import asyncio
import subprocess


def _ping(ip):
    print(f"pinging {ip}")
    command = ["ping", "-c", "1", "-i", "0.5", ip]
    resp = subprocess.run(command, capture_output=True)
    if resp.returncode > 0:
        return False, ip
    return True, ip


async def main():
    hostname_cmd = subprocess.run(
        ["hostname", "-I"], capture_output=True, text=True
    )
    inet = ".".join(hostname_cmd.stdout.split(".")[:3])
    tasks = [asyncio.to_thread(_ping, f"{inet}.{n}") for n in range(1, 32)]
    results = await asyncio.gather(*tasks)
    for val, ip in results:
        if val:
            print(ip)


if __name__ == "__main__":
    asyncio.run(main())
