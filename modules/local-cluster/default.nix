{ config, pkgs, ... }:

{
  systemd.services.k3d-cluster = {
    description = "Manage k3d cluster lifecycle";
    after = [
      "docker.service"
      "network-online.target"
    ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      User = "quanthai";
      Group = "docker";
      TimeoutStartSec = "120";
      TimeoutStopSec = "60";

      Environment = [
        "PATH=/run/current-system/sw/bin:/home/quanthai/.local/bin"
        "HOME=/home/quanthai"
      ];

      ExecStart =
        let
          start-k3d = pkgs.writeShellScript "start-k3d-cluster" ''
            set -euo pipefail
            echo "$(date): Starting k3d cluster 'local'"

            if ${pkgs.k3d}/bin/k3d cluster list --no-headers | ${pkgs.gnugrep}/bin/grep -q "^local"; then
              echo "$(date): Cluster 'local' exists, starting it"
              ${pkgs.k3d}/bin/k3d cluster start local
            else
              echo "$(date): Cluster 'local' does not exist"
              exit 1
            fi

            echo "$(date): k3d cluster start complete"
          '';
        in
        "${start-k3d}";

      ExecStop =
        let
          stop-k3d = pkgs.writeShellScript "stop-k3d-cluster" ''
            set -euo pipefail
            echo "$(date): Stopping k3d cluster 'local'"

            if ${pkgs.k3d}/bin/k3d cluster list --no-headers | ${pkgs.gnugrep}/bin/grep -q "^local"; then
              ${pkgs.k3d}/bin/k3d cluster stop local
              echo "$(date): k3d cluster stop complete"
            else
              echo "$(date): Cluster 'local' does not exist"
            fi
          '';
        in
        "${stop-k3d}";
    };
  };

  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  services.displayManager.gdm.autoSuspend = false;

  boot.kernelParams = [
    "consoleblank=300"
    "intel_pstate=passive"
  ];

  powerManagement.cpuFreqGovernor = "powersave";

  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "powersave";
      CPU_ENERGY_PERF_POLICY_ON_AC = "power";
      WIFI_PWR_ON_AC = "off";
      PCIE_ASPM_ON_AC = "powersave";
      SATA_LINKPWR_ON_AC = "med_power_with_dipm";
      USB_AUTOSUSPEND = 1;
    };
  };

  services.power-profiles-daemon.enable = false;

  networking.networkmanager.settings = {
    connection = {
      "wifi.powersave" = 2;
    };
  };
}
