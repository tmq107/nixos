{ lib, ... }:

let
  username = "quanthai";
  sourceRoot = ./home;

  relativeFiles = map (path: lib.removePrefix "./" (lib.path.removePrefix sourceRoot path)) (
    lib.filesystem.listFilesRecursive sourceRoot
  );
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
