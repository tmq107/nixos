# NixOS configuration

NixOS flake configuration for WSL, laptop, and local cluster machines.

## Repository structure

```text
.
├── flake.nix                 # Flake entrypoint and host definitions
├── base/                     # Shared NixOS and Home Manager configuration
├── hosts/                    # Host-specific configuration
│   ├── wsl/
│   ├── hp15a/
│   └── t90plus/
├── modules/                  # Reusable system and user modules
│   ├── agent/                # AI agent tools
│   ├── cli/                  # CLI tools
│   ├── cloud/                # Cloud tools
│   ├── desktop/              # KDE, audio, input method
│   │   └── browser/          # Firefox configuration
│   ├── dev/                  # Development tools
│   ├── disk/                 # Disko configuration
│   ├── dotfiles/             # Home Manager dotfile symlinks
│   │   └── home/             # User dotfiles and config files
│   ├── games/                # Games and gaming tools
│   ├── local-cluster/        # k3d and cluster-machine power settings
│   ├── neovim/               # Neovim and language servers
│   ├── terminal/             # Terminal configuration
│   └── work/                 # Work-specific modules
├── notes/                    # Personal notes
├── scripts/                  # Helper scripts
│   └── build.py              # Rebuild wrapper and preflight checks
├── Makefile                 # Common commands
└── flake.lock               # Locked flake inputs
```

## Build and install

Install required tools:

```bash
nix-shell -p git gnumake neovim disko
```

Build and activate a host:

```bash
make build host=wsl
make build host=hp15a
make build host=t90plus
```

The build wrapper checks these files before rebuilding:

```text
~/.config/sops/age/keys.txt
~/.ssh/id_ed25519
~/.ssh/id_ed25519.pub
```

Fresh `t90plus` installation:

```bash
make disko host=t90plus-install
make install host=t90plus-install
make build host=t90plus
```

Update all flake inputs:

```bash
make update
```

Update one flake input:

```bash
make update-input input=nixpkgs
```

Format Nix files:

```bash
make fmt
```

Clean old Nix generations:

```bash
make clean
```

Running `make` executes the default `fmt` target.

## Dotfiles

User dotfiles live under:

```text
modules/dotfiles/home/
```

Home Manager creates out-of-store symlinks into this directory. Add files there, then rebuild:

```bash
make build host=wsl
```

Keep private keys and other secrets outside the repository. The SOPS age key and SSH keys are checked by `scripts/build.py`, but are not copied into the NixOS configuration.

## Acknowledgements
- [khuedoan/dotfiles](https://github.com/khuedoan/dotfiles)
