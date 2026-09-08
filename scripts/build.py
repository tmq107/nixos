#!/usr/bin/env python3

import os
import shutil
import sys


REQUIRED_FILES = [
    "~/.config/sops/age/keys.txt",
    "~/.ssh/id_ed25519",
    "~/.ssh/id_ed25519.pub",
]

DEFAULT_NIX_ARGS = [
    "--option",
    "http-connections",
    "50",
    "switch",
    "--impure",
]


def check_required_files() -> None:
    missing = [
        path for path in REQUIRED_FILES
        if not os.path.isfile(os.path.expanduser(path))
    ]

    if missing:
        print("Missing required files:", file=sys.stderr)
        for path in missing:
            print(f"  {os.path.expanduser(path)}", file=sys.stderr)
        raise SystemExit(1)


def main() -> None:
    check_required_files()

    if shutil.which("nixos-rebuild") is None:
        raise SystemExit("Error: nixos-rebuild not found")

    repo_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    os.environ["DOTFILES_DIR"] = repo_root

    command = [
        "sudo",
        "--preserve-env=DOTFILES_DIR",
        "nixos-rebuild",
        *DEFAULT_NIX_ARGS,
        *sys.argv[1:],
    ]

    os.execvpe(command[0], command, os.environ)


if __name__ == "__main__":
    main()
