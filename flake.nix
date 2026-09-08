{
  description = "NixOS";

  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-26.05";
    };
    nixpkgs-unstable = {
      url = "github:nixos/nixpkgs/nixpkgs-unstable";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware = {
      url = "github:NixOS/nixos-hardware/master";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/main";
    };
    llm-agents = {
      url = "github:numtide/llm-agents.nix";
    };
    sofka = {
      url = "github:nklmilojevic/sofka";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      disko,
      nixos-hardware,
      home-manager,
      nixos-wsl,
      llm-agents,
      sofka,
    }:
    let
      systemModules = [
        disko.nixosModules.disko
        ./base
        home-manager.nixosModules.home-manager
        {
          nixpkgs.overlays = [
            (final: prev: {
              unstable = import nixpkgs-unstable {
                inherit (prev.stdenv.hostPlatform) system;
                config = prev.config;
              };
              llm-agents = llm-agents.packages.${prev.stdenv.hostPlatform.system};
              sofka = sofka.packages.${prev.stdenv.hostPlatform.system}.default;
            })
          ];
        }
      ];

      baseModules = systemModules ++ [
        ./modules/dotfiles
        ./modules/terminal/kitty.nix
        ./modules/cli
        ./modules/neovim
      ];
    in
    {
      nixosConfigurations = {
        wsl = nixpkgs.lib.nixosSystem {
          modules = baseModules ++ [
            nixos-wsl.nixosModules.default
            ./hosts/wsl
            ./modules/work/tecalliance
            ./modules/work/playground
            ./modules/cloud
            ./modules/dev
            ./modules/agent
          ];
        };
        hp15a = nixpkgs.lib.nixosSystem {
          modules = baseModules ++ [
            ./hosts/hp15a/hardware-configuration.nix
            ./hosts/hp15a
            ./modules/desktop
            ./modules/cloud
            ./modules/dev
            ./modules/agent
            ./modules/games
          ];
        };
        t90plus = nixpkgs.lib.nixosSystem {
          modules = baseModules ++ [
            ./hosts/t90plus
            ./modules/desktop
            ./modules/disk
            ./modules/local-cluster
            ./modules/cloud
            ./modules/dev
            ./modules/agent
          ];
        };

        t90plus-install = nixpkgs.lib.nixosSystem {
          modules = systemModules ++ [
            ./hosts/t90plus
            ./modules/desktop
            ./modules/disk
          ];
        };
      };
    };
}
