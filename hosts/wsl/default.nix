{ lib, pkgs, ... }:

{
  imports = [ ./vscode.nix ];

  environment.systemPackages = with pkgs; [
    wsl-vpnkit
  ];

  wsl = {
    enable = true;
    defaultUser = "quanthai";
  };

  nixpkgs = {
    hostPlatform = "x86_64-linux";
    config = {
      allowUnfree = true;
    };
  };

  networking = {
    hostName = "wsl";
    enableIPv6 = false;
    networkmanager.enable = lib.mkForce false;
  };

  systemd.services.wpa_supplicant.enable = false;

  # Start wsl-vpnkit
  systemd.services = {
    wsl-vpnkit-auto = {
      enable = true;
      description = "wsl-vpnkit";

      path = [ pkgs.iputils ];
      script = ''
        has_internet () {
          ping -q -w 1 -c 1 8.8.8.8 >/dev/null
        }

        has_company_network () {
          ping -q -w 1 -c 1 google.com >/dev/null
        }

        is_active_wsl-vpnkit () {
          systemctl is-active -q wsl-vpnkit.service
        }

        main () {
          if is_active_wsl-vpnkit; then
            if has_internet && ! has_company_network; then
              echo "Stopping wsl-vpnkit..."
              systemctl stop wsl-vpnkit.service
            fi
          else
            if ! has_internet; then
              echo "Starting wsl-vpnkit..."
              systemctl start wsl-vpnkit.service
            fi
          fi
        }

        while :
        do
          main
          sleep 5
        done
      '';

      wantedBy = [ "multi-user.target" ];
    };

    wsl-vpnkit = {
      enable = true;
      description = "wsl-vpnkit";
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        ExecStart = "${pkgs.wsl-vpnkit}/bin/wsl-vpnkit";
        Type = "idle";
        Restart = "always";
        KillMode = "mixed";
      };
    };
  };

  services.tailscale = {
    enable = true;
    extraUpFlags = [
      "--accept-dns=false"
    ];
  };

  vscode-remote-workaround = {
    enable = true;
  };

  programs = {
    nix-ld = {
      enable = true;
    };
  };
}
