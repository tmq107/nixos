{ pkgs, ... }:

{
  services.cloudflare-warp = {
    enable = true;
    package = pkgs.cloudflare-warp;
  };

  environment.systemPackages = [ pkgs.cloudflare-warp ];

  systemd.services.warp = {
    description = "Cloudflare WARP connection";
    after = [ "cloudflare-warp.service" "network-online.target" ];
    requires = [ "cloudflare-warp.service" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.cloudflare-warp}/bin/warp-cli connect";
      ExecStop = "${pkgs.cloudflare-warp}/bin/warp-cli disconnect";
    };
  };
}
