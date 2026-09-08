{ config, pkgs, ... }:

{
  imports = [
    ./browser/firefox.nix
  ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  virtualisation = {
    libvirtd.enable = true;
  };

  # Desktop permission/security helpers
  security = {
    polkit.enable = true;
    rtkit.enable = true;
  };

  # Services
  services = {
    dbus.enable = true;
    gvfs.enable = true;
    xserver.enable = true;
    displayManager.sddm.enable = true;
    desktopManager.plasma6.enable = true;

    pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
    };
  };

  # Hardware
  hardware = {
    enableAllHardware = true;
    bluetooth.enable = true;
  };

  programs = {
    direnv = {
      enable = true;
      silent = true;
    };

    virt-manager.enable = true;
  };

  security.sudo.wheelNeedsPassword = true;

  environment = {
    systemPackages = with pkgs; [
      # KDE default
      kdePackages.ark
      kdePackages.dolphin
      kdePackages.konsole
      kdePackages.okular
      kdePackages.spectacle

      pavucontrol
      xdg-utils

      # Input Language
      qt6Packages.fcitx5-configtool
      kdePackages.fcitx5-qt
      libsForQt5.fcitx5-qt

    ];

    sessionVariables = {
      TERMINAL = "wezterm";
      GTK_IM_MODULE = "fcitx";
      QT_IM_MODULE = "fcitx";
      XMODIFIERS = "@im=fcitx";
      SDL_IM_MODULE = "fcitx";
    };
  };

  # Bootloader for separate NixOS EFI partition mounted at /boot
  boot = {
    loader = {
      systemd-boot = {
        enable = true;

        # Important: prevent /boot from filling again
        configurationLimit = 3;
      };

      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot";
      };
    };
  };

  i18n = {
    inputMethod = {
      enable = true;
      type = "fcitx5";

      fcitx5 = {
        addons = with pkgs; [
          fcitx5-bamboo
        ];

        settings = {
          inputMethod = {
            "Groups/0" = {
              "Name" = "Default";
              "Default Layout" = "us";
              "DefaultIM" = "bamboo";
            };

            "Groups/0/Items/0" = {
              "Name" = "keyboard-us";
            };

            "Groups/0/Items/1" = {
              "Name" = "bamboo";
            };
          };

          globalOptions = {
            "Behavior" = {
              "ShowInputMethodInformation" = "False";
            };

            "Hotkey/TriggerKeys" = {
              "0" = "Control+space";
            };

            "Hotkey/EnumerateForwardKeys" = {
              "0" = "Control+Shift+space";
            };
          };

          addons = {
            bamboo = {
              globalSection = {
                InputMethod = "VNI";
              };
            };
          };
        };
      };
    };
  };
}
