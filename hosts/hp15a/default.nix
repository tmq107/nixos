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

  networking = {
    hostName = "hp15a";
  };
}
