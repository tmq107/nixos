{
  config,
  lib,
  pkgs,
  ...
}:

{
  environment.systemPackages =
    with pkgs;
    [
      kitty
    ]
    ++ lib.optionals (config.wsl.enable or false) [
      mesa-demos
    ];

  fonts = {
    packages = with pkgs; [
      nerd-fonts.fira-code
    ];

    fontconfig.enable = true;
  };
}
