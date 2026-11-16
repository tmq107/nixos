{ config, modulesPath, ... }:

{
  imports = [ "${modulesPath}/virtualisation/amazon-image.nix" ];

  nixpkgs.hostPlatform = "x86_64-linux";

  networking = {
    hostName = "ec2-test";
    firewall = {
      enable = true;
      trustedInterfaces = [ "tailscale0" ];
      allowedUDPPorts = [ config.services.tailscale.port ];
    };
  };

  services.tailscale.enable = true;
}
