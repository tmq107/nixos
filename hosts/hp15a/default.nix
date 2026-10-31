{ config, pkgs, ... }:

{
  nixpkgs = {
    hostPlatform = "x86_64-linux";
    config = {
      allowUnfree = true;
    };
  };

  environment.systemPackages = with pkgs; [
    libnotify
  ];

  services = {
    tailscale.enable = true;
  };

  home-manager.users.quanthai.xdg.configFile."niri/outputs.kdl".text = ''
    output "HDMI-A-1" {
      position x=0 y=0
    }

    output "eDP-1" {
      position x=2560 y=0
    }
  '';

  networking = {
    hostName = "hp15a";
  };
}
