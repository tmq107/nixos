.POSIX:
.PHONY: default build diff update fmt clean disko install update-input

default: fmt

build:
	./scripts/build.py \
		--flake '.#$(host)'

disko:
	sudo nix --extra-experimental-features "nix-command flakes" run github:nix-community/disko#disko -- \
		--mode destroy,format,mount \
		--flake '.#$(host)'

install:
	sudo nixos-install \
		--flake '.#$(host)' \
		--root /mnt \
		--option build-dir /mnt/nix-build-tmp

fmt:
	nix run nixpkgs#nixfmt-tree

update:
	nix flake update

update-input:
	nix flake lock --update-input "$(input)"

clean:
	nix-collect-garbage --delete-old --log-format bar

