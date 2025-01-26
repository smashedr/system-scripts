#!/usr/bin/env python3
# C:\Apps\Python311\python.EXE C:\Users\Shane\IdeaProjects\system-scripts\qbittorrent\discord.py "%N" "%Z" "%L" "%C" "discord-webhook"

import json
import requests
import sys


def send_discord(message: str, webhook: str) -> requests.Response:
    """
    Send Discord Message
    """
    headers = {"Content-Type": "application/json"}
    body = {"content": message}
    return requests.post(webhook, data=json.dumps(body), headers=headers, timeout=10)


def fmt_bytes(num, suffix="B"):
    if not num.isnumeric():
        return num
    num = int(num)
    for unit in ("", "Ki", "Mi", "Gi", "Ti", "Pi", "Ei", "Zi"):
        if abs(num) < 1024.0:
            return f"{num:3.1f}{unit}{suffix}"
        num /= 1024.0
    return f"{num:.1f}Yi{suffix}"


name = sys.argv[1]
size = fmt_bytes(sys.argv[2])
cat = sys.argv[3]
files = sys.argv[4]
hook = sys.argv[5]

output = f":file_folder: `{cat or 'unknown'}` ({files}) **{name}** {size}"
print(f"output: {output}")
r = send_discord(output, hook)
if not r.ok:
    raise ValueError("Error sending to discord webhook: %s", r.status_code)
