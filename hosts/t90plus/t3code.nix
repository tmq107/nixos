{ config, pkgs, ... }:

{
  environment.systemPackages = [ pkgs.llm-agents.t3code ];

  services.nginx = {
    enable = true;
    virtualHosts.t3code = {
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
        proxyPass = "http://127.0.0.1:3773";
        proxyWebsockets = true;
        extraConfig = ''
          proxy_set_header Host $host;
          proxy_set_header X-Forwarded-Proto $http_x_forwarded_proto;
          proxy_read_timeout 1h;
        '';
      };
    };
  };

  home-manager.users.quanthai.systemd.user.services.t3code = {
    Unit = {
      Description = "T3 Code web server";
      After = [ "default.target" ];
    };
    Install.WantedBy = [ "default.target" ];
    Service = {
      Environment = [
        "PATH=/run/wrappers:/run/current-system/sw/bin:/home/quanthai/.local/bin"
      ];
      WorkingDirectory = "/home/quanthai";
      ExecStart = "${pkgs.llm-agents.t3code}/bin/t3 serve --host 127.0.0.1 --port 3773";
      Restart = "on-failure";
      RestartSec = 5;
      UMask = "0077";
    };
  };

  systemd.services.t3code-tailscale = {
    description = "T3 Code HTTPS access over Tailscale";
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
      ExecStart = "${config.services.tailscale.package}/bin/tailscale serve --bg --https=8443 http://127.0.0.1:3772";
    };
  };
}
