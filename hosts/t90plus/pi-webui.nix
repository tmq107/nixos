{ config, pkgs, ... }:

{
  services.nginx = {
    enable = true;
    virtualHosts.pi-webui = {
      listen = [
        {
          addr = "127.0.0.1";
          port = 3772;
        }
      ];
      extraConfig = ''
        if ($http_tailscale_user_login != "tmq107@github") {
          return 403;
        }
      '';
      locations."/" = {
        proxyPass = "http://127.0.0.1:8787";
        proxyWebsockets = true;
        extraConfig = ''
          proxy_set_header Host $host;
          proxy_set_header X-Forwarded-Proto https;
          proxy_read_timeout 1h;
        '';
      };
    };
  };

  systemd.services.pi-webui = {
    description = "Pi web UI";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];

    serviceConfig = {
      User = "quanthai";
      WorkingDirectory = "/home/quanthai";
      Environment = [ "HOME=/home/quanthai" ];
      ConditionFileIsExecutable = "/home/quanthai/.local/bin/pi-webui";
      # Zsh automatically loads .zshenv; source custom secret env explicitly.
      ExecStart = "${pkgs.zsh}/bin/zsh -c 'source /home/quanthai/.zshenv_secret; exec /home/quanthai/.local/bin/pi-webui'";
      Restart = "on-failure";
      RestartSec = 5;
      UMask = "0077";
    };
  };

  systemd.services.pi-webui-tailscale = {
    description = "Pi web UI HTTPS access over Tailscale";
    wantedBy = [ "multi-user.target" ];
    wants = [
      "tailscaled.service"
      "nginx.service"
    ];
    after = [
      "tailscaled.service"
      "nginx.service"
    ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${config.services.tailscale.package}/bin/tailscale serve --bg --https=443 http://127.0.0.1:3772";
    };
  };
}
