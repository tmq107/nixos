from pathlib import Path
src = Path.cwd() / "modules/dotfiles/home"
home = Path.home()
for path in src.rglob("*"):
    if path.is_file():
        target = home / path.relative_to(src)
        if target.is_file() and not target.is_symlink():
            target.unlink()
            print("removed", target)

