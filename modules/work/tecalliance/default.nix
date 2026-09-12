{ pkgs, ... }:

let
  dotfilesDir = builtins.getEnv "DOTFILES_DIR";
  repoRoot = if dotfilesDir != "" then dotfilesDir else "/home/quanthai/personal/nixos";
in
{
  home-manager.users.quanthai =
    { config, ... }:
    {
      home.file = {
        ".local/bin/tec_alarm" = {
          force = true;
          source = config.lib.file.mkOutOfStoreSymlink
            "${repoRoot}/modules/work/tecalliance/scripts/tec_alarm";
        };
        ".local/bin/tec_deploy" = {
          force = true;
          source = config.lib.file.mkOutOfStoreSymlink
            "${repoRoot}/modules/work/tecalliance/scripts/tec_deploy";
        };
        ".local/bin/tec_snapshot" = {
          force = true;
          source = config.lib.file.mkOutOfStoreSymlink
            "${repoRoot}/modules/work/tecalliance/scripts/tec_snapshot";
        };
      };
    };

  users.users.quanthai = {
    packages = with pkgs; [
      (azure-cli.withExtensions [
        azure-cli-extensions.azure-devops
      ])
      direnv
      pre-commit
      unstable.kiro-cli
    ];
  };
}
