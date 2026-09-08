{ pkgs, ... }:

{
  users.users.quanthai = {
    packages = with pkgs; [

      # aws cli support
      awscli2
      ssm-session-manager-plugin
      granted

      # kubernetes
      sofka
      kubectl
      (wrapHelm kubernetes-helm {
        plugins = with kubernetes-helmPlugins; [
          helm-diff
        ];
      })
      kustomize
      k3d
      fluxcd

      # IAC tool
      tenv

      # ssh private tool
      unstable.tailscale
    ];
  };
}
