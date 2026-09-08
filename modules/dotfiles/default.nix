{ lib, ... }:

let
  username = "quanthai";
  sourceRoot = ./home;

  discoveredFiles = map (
    path: lib.removePrefix "./" (lib.path.removePrefix sourceRoot path)
  ) (lib.filesystem.listFilesRecursive sourceRoot);

  # Keep machine-local files out of Git while still linking them through Home Manager.
  localFiles = [
    ".config/kiro/settings"
    ".config/sofka/clusters"
    ".local/bin/notify-send"
    ".zshenv_secret"
  ];

  relativeFiles = lib.unique (discoveredFiles ++ localFiles);
in
{
  home-manager.users.${username} =
    { config, ... }:

    let
      dotfilesDir = builtins.getEnv "DOTFILES_DIR";
      repoRoot = if dotfilesDir != "" then dotfilesDir else "/home/quanthai/personal/nixos";
    in
    {
      home.file = lib.genAttrs relativeFiles (relativePath: {
        force = true;
        source = config.lib.file.mkOutOfStoreSymlink "${repoRoot}/modules/dotfiles/home/${relativePath}";
      });
    };
}
