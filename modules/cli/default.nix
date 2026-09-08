{ pkgs, ... }:

{
  users.users.quanthai = {
    packages = with pkgs; [
      # cat alternative
      bat

      # monitoring
      btop
      lsof
      duf
      unstable.witr

      # find file or grep
      fzf
      fd
      ripgrep

      # github cli
      gh

      # fastfetch
      zoxide
      fastfetch

      # automation taskfile
      go-task

      # zsh support
      zsh-completions

      # secret encryption
      sops
      age

      # jq / yq support
      jq
      yq-go

      # docker support tool
      unstable.docker-compose
      dive

      # terminal for AI
      unstable.herdr
    ];
  };
}
