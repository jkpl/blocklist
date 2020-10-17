#!/usr/bin/env python3

import sys
import os

TARGET_IP=os.getenv("TARGET_IP", "0.0.0.0")
NOT_EXTERNAL_HOSTNAME=set((
    "127.0.0.1",
    "0.0.0.0",
    "::1",
    "localhost",
))

def is_external_hostname(s):
    return not s in NOT_EXTERNAL_HOSTNAME

def clean_line(line):
    # Filter out commented lines
    if line.startswith("#"):
        return None

    # Filter out empty lines
    if line.isspace() or not line:
        return None

    host = next((
        part for part in line.split()
        if is_external_hostname(part)
    ), "")

    if host:
        return f"address=/{host}/{TARGET_IP}"
    return None

def main(sourcefile, outputfile):
    try:
        if outputfile:
            output = open(outputfile, "a")
        else:
            output = sys.stderr
        with open(sourcefile) as fp:
            for line in fp:
                cleaned_line = clean_line(line)
                if cleaned_line:
                    print(cleaned_line, file=output)
    finally:
        output.close()

if __name__ == "__main__":
    if len(sys.argv) > 2:
        main(sys.argv[1], sys.argv[2])
    else:
        main(sys.argv[1], None)

