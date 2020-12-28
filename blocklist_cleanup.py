#!/usr/bin/env python3

import sys
import os
import re

WHITELIST_PATH=os.getenv("WHITELIST_PATH", "whitelist.txt")
TARGET_IP=os.getenv("TARGET_IP", "0.0.0.0")
NOT_EXTERNAL_HOSTNAME=set((
    "127.0.0.1",
    "0.0.0.0",
    "::1",
    "localhost",
))

def load_whitelist():
    try:
        with open(WHITELIST_PATH) as fp:
            lines = (re.compile(line.strip()) for line in fp.readlines())
            return list(lines)
    except FileNotFoundError:
        return list()

def is_whitelisted(whitelist, host):
    for r in whitelist:
        if r.match(host):
            return True
    return False

def is_external_hostname(s):
    return not s in NOT_EXTERNAL_HOSTNAME

def clean_line(line, whitelist):
    # Filter out commented lines
    if line.startswith("#"):
        return None

    # Filter out empty lines
    if line.isspace() or not line:
        return None

    # Extract hostname from the line
    host = next((
        part for part in line.split()
        if is_external_hostname(part)
    ), "")

    # Filter out whitelisted hosts
    if is_whitelisted(whitelist, host):
        return None

    # Print hosts in dnsmasq format
    if host:
        return f"address=/{host}/{TARGET_IP}"

    return None

def main(sourcefile, outputfile):
    whitelist = load_whitelist()
    try:
        if outputfile:
            output = open(outputfile, "a")
        else:
            output = sys.stderr
        with open(sourcefile) as fp:
            for line in fp:
                cleaned_line = clean_line(line, whitelist)
                if cleaned_line:
                    print(cleaned_line, file=output)
    finally:
        output.close()

if __name__ == "__main__":
    if len(sys.argv) > 2:
        main(sys.argv[1], sys.argv[2])
    else:
        main(sys.argv[1], None)

