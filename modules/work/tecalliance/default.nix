{ pkgs, ... }:

{
  users.users.quanthai = {
    packages = with pkgs; [
      (azure-cli.withExtensions [
        azure-cli-extensions.azure-devops
      ])
      direnv
      eksctl
      pre-commit
      unstable.kiro-cli
    ];
  };
}
