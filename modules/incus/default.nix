{ ... }:

{
  networking.nftables.enable = true;
  networking.firewall.interfaces.incusbr0 = {
    allowedTCPPorts = [ 22 53 ];
    allowedUDPPorts = [ 53 67 ];
  };

  users.users.quanthai.extraGroups = [ "incus-admin" ];

  virtualisation.incus = {
    enable = true;
    preseed = {
      storage_pools = [
        {
          name = "default";
          driver = "dir";
          config.source = "/var/lib/incus/storage-pools/default";
        }
      ];
      networks = [
        {
          name = "incusbr0";
          type = "bridge";
          config = {
            "ipv4.address" = "auto";
            "ipv4.nat" = "true";
            "ipv4.dhcp" = "true";
            "dns.nameservers" = "1.1.1.1,1.0.0.1";
          };
        }
      ];
      profiles = [
        {
          name = "default";
          config."security.secureboot" = "false";
          devices = {
            root = {
              type = "disk";
              path = "/";
              pool = "default";
            };
            eth0 = {
              type = "nic";
              name = "eth0";
              network = "incusbr0";
            };
          };
        }
      ];
    };
  };
}
