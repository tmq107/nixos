{ config, pkgs, ... }:

let
  gopass = "${pkgs.unstable.gopass}/bin/gopass";
  startT3 = pkgs.writeShellScript "t3code-start" ''
    set -euo pipefail
    set +x

    : "''${CREDENTIALS_DIRECTORY:?Missing systemd credentials}"
    pin="$(<"$CREDENTIALS_DIRECTORY/gopass-pin")"
    if [[ -z "$pin" ]]; then
      echo "Missing gopass PIN" >&2
      exit 1
    fi

    GOPASS_AGE_PASSWORD="$pin" ${gopass} age agent unlock </dev/null >/dev/null
    unset pin GOPASS_AGE_PASSWORD

    # Separate assignments from exports so failed reads stop startup.
    CLOUDFLARE_API_TOKEN="$(${gopass} show -o personal/cloudflare/token)"
    GMAIL_OAUTH_CLIENT_ID="$(${gopass} show -o personal/gmail/oauth_id)"
    GMAIL_OAUTH_CLIENT_SECRET="$(${gopass} show -o personal/gmail/oauth_secret)"
    MODELAPI_API_KEY="$(${gopass} show -o personal/model/api_key)"
    MODELAPI_USAGE_API_KEY="$(${gopass} show -o personal/model/usage_key)"
    export CLOUDFLARE_API_TOKEN GMAIL_OAUTH_CLIENT_ID GMAIL_OAUTH_CLIENT_SECRET
    export MODELAPI_API_KEY MODELAPI_USAGE_API_KEY

    exec ${pkgs.llm-agents.t3code}/bin/t3 serve --host 127.0.0.1 --port 3773
  '';
in
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

  # Create PIN manually on the host; never put its contents in Nix or Git.
  systemd.tmpfiles.rules = [ "d /var/lib/gopass-unlock 0700 root root -" ];

  systemd.services.t3code = {
    description = "T3 Code web server";
    wantedBy = [ "multi-user.target" ];
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    path = [
      "/run/wrappers"
      "/run/current-system/sw"
      "/etc/profiles/per-user/quanthai"
      "/home/quanthai/.local"
    ];
    environment = {
      HOME = "/home/quanthai";
      XDG_CONFIG_HOME = "/home/quanthai/.config";
      XDG_RUNTIME_DIR = "/run/t3code";
      PI_CODING_AGENT_DIR = "/home/quanthai/personal/pi-agent/agent";
    };
    serviceConfig = {
      User = "quanthai";
      WorkingDirectory = "/home/quanthai";
      RuntimeDirectory = "t3code";
      RuntimeDirectoryMode = "0700";
      LoadCredential = [ "gopass-pin:/var/lib/gopass-unlock/pin" ];
      ExecStart = startT3;
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
