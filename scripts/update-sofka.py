#!/usr/bin/env python3
"""Update the pinned Sofka Linux release version and archive hash."""

import argparse
import base64
import json
import re
import urllib.request
from pathlib import Path

API_URL = "https://api.github.com/repos/nklmilojevic/sofka/releases/latest"
PACKAGE_FILE = Path(__file__).resolve().parent.parent / "packages" / "sofka.nix"
ASSET_TEMPLATE = "sofka-v{version}-x86_64-unknown-linux-musl.tar.gz"


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--dry-run", action="store_true", help="show update without changing files")
    args = parser.parse_args()

    request = urllib.request.Request(
        API_URL,
        headers={"Accept": "application/vnd.github+json", "User-Agent": "nixos-sofka-updater"},
    )
    with urllib.request.urlopen(request, timeout=30) as response:
        release = json.load(response)

    tag = release.get("tag_name", "")
    if not re.fullmatch(r"v\d+\.\d+\.\d+", tag):
        raise SystemExit(f"Unexpected Sofka release tag: {tag!r}")
    version = tag[1:]

    asset_name = ASSET_TEMPLATE.format(version=version)
    asset = next((item for item in release.get("assets", []) if item.get("name") == asset_name), None)
    digest = asset.get("digest") if asset else None
    if not isinstance(digest, str) or not re.fullmatch(r"sha256:[0-9a-fA-F]{64}", digest):
        raise SystemExit(f"Missing valid GitHub SHA-256 digest for release asset {asset_name}")
    sri_hash = "sha256-" + base64.b64encode(bytes.fromhex(digest.split(":", 1)[1])).decode("ascii")

    contents = PACKAGE_FILE.read_text()
    updated, version_count = re.subn(r'(?m)^  version = "[^"]+";$', f'  version = "{version}";', contents, count=1)
    updated, hash_count = re.subn(r'(?m)^    hash = "sha256-[^"]+";$', f'    hash = "{sri_hash}";', updated, count=1)
    if version_count != 1 or hash_count != 1:
        raise SystemExit(f"Could not uniquely update version and hash in {PACKAGE_FILE}")

    print(f"Sofka: {tag}; asset: {asset_name}; {sri_hash}")
    if args.dry_run:
        print("Dry run; no files changed.")
        return

    PACKAGE_FILE.write_text(updated)
    print(f"Updated {PACKAGE_FILE}")


if __name__ == "__main__":
    main()
