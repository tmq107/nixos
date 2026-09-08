{
  config,
  pkgs,
  lib,
  ...
}:
{
  config = {
    users.users.quanthai = {
      isNormalUser = true;
      description = "Quan Thai";
      extraGroups = [
        "docker"
        "libvirtd"
        "networkmanager"
        "tss"
        "video"
        "wheel"
      ];
      shell = pkgs.zsh;
    };

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      users.quanthai = {
        home = {
          stateVersion = "26.05";
          sessionVariables = {
            XDG_RUNTIME_DIR = "/run/user/1000";
          };
        };
        services.easyeffects.enable = true;
      };
    };

    networking = {
      networkmanager = {
        enable = true;
      };
      firewall = {
        checkReversePath = "loose";
      };
    };

    systemd = {
      services = {
        NetworkManager-wait-online = {
          enable = false;
        };
      };
    };

    time.timeZone = "Asia/Ho_Chi_Minh";

    i18n = {
      defaultLocale = "en_US.UTF-8";
    };

    nix = {
      settings = {
        experimental-features = [
          "nix-command"
          "flakes"
        ];
      };
      optimise.automatic = true;
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 7d";
      };
    };

    # List packages installed in system profile.
    environment = {
      systemPackages = with pkgs; [
        # Core Utilities
        curl
        wget
        file
        git
        killall
        tmux
        tree
        unzip
        watch
        bind

        # Programming Languages
        python3
        gcc
        gnumake
      ];
    };

    programs = {
      zsh = {
        enable = true;
        enableCompletion = true;
      };
    };

    virtualisation = {
      docker = {
        enable = true;
        enableOnBoot = true;
        autoPrune = {
          enable = false;
          flags = [
            "--all"
            "--volumes"
          ];
        };

        daemon.settings = {
          dns = [
            "1.1.1.1"
            "8.8.8.8"
          ];
        };
      };
    };

    system.stateVersion = "26.05";

  };
}
