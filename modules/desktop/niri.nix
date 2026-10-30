{ pkgs, ... }:

{
  programs.niri.enable = true;

  environment.systemPackages = with pkgs; [
    unstable.noctalia
    soteria
    wl-clipboard
  ];

  home-manager.users.quanthai.gtk = {
    enable = true;
    colorScheme = "dark";
  };
}
