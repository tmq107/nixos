{ lib, ... }:

let
  username = "quanthai";
  sourceRoot = ./home;

  discoveredFiles = map (
    path: lib.removePrefix "./" (lib.path.removePrefix sourceRoot path)
  ) (lib.filesystem.listFilesRecursive sourceRoot);


in
{
  home-manager.users.${username} =
    { config, ... }:

    let
      dotfilesDir = builtins.getEnv "DOTFILES_DIR";
      repoRoot = if dotfilesDir != "" then dotfilesDir else "/home/quanthai/personal/nixos";

      # Keep machine-local files out of Git and skip links when source is absent.
      localFiles = [
        ".config/kiro/settings"
        ".config/sofka/clusters"
        ".local/bin/notify-send"
        ".zshenv_secret"
      ];

      relativeFiles = lib.unique (
        discoveredFiles
        ++ lib.filter (
          relativePath:
          builtins.pathExists "${repoRoot}/modules/dotfiles/home/${relativePath}"
        ) localFiles
      );
    in
    {
      home.file = lib.genAttrs relativeFiles (relativePath: {
        force = true;
        source = config.lib.file.mkOutOfStoreSymlink "${repoRoot}/modules/dotfiles/home/${relativePath}";
      });
    };
}
