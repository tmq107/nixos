from pathlib import Path

src = Path.cwd() / "modules/dotfiles/home"
home = Path.home()

bad = []
for path in src.rglob("*"):
    if path.is_file():
        target = home / path.relative_to(src)
        if not target.is_symlink() or target.resolve() != path.resolve():
            bad.append((target, path))

print("bad:", len(bad))
for target, expected in bad:
    print(target, "expected", expected)

