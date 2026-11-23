{ config, pkgs, ... }:

{
  services.openssh.enable = true;

  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    devices = [ "nodev" ];
    efiInstallAsRemovable = true;
  };

  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  nixpkgs = {
    hostPlatform = "x86_64-linux";
    config = {
      allowUnfree = true;
    };
  };

  environment.systemPackages = with pkgs; [
    libnotify
  ];

  systemd.services.daily-poweroff = {
    description = "Daily poweroff at 7PM UTC+7";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "/run/current-system/sw/bin/systemctl poweroff";
    };
  };

  systemd.timers.daily-poweroff = {
    description = "Daily poweroff timer at 7PM UTC+7";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*-*-* 12:00:00 UTC";
      Persistent = true;
    };
  };

  services = {
    tailscale.enable = true;
  };

  disko.devices.disk.main.device = "/dev/sda";

  networking = {
    hostName = "t90plus";
    firewall = {
      enable = true;

      # Crucial: This tells NixOS not to block traffic coming from your Tailnet
      trustedInterfaces = [ "tailscale0" ];

      # Optional: Open Tailscale's default UDP port for faster direct mesh connections
      allowedUDPPorts = [ config.services.tailscale.port ];
    };
  };
}
