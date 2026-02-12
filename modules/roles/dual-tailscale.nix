{ config, pkgs, lib, ... }:

{
  # Disable native Tailscale — Docker containers handle both tailnets
  services.tailscale.enable = lib.mkForce false;

  # Ensure tun device is available for Tailscale containers
  boot.kernelModules = [ "tun" ];

  # Persistent state directories for each Tailscale instance
  systemd.tmpfiles.rules = [
    "d /srv/tailscale-primary 0700 root root -"
    "d /srv/tailscale-secondary 0700 root root -"
  ];

  virtualisation.oci-containers.containers = {
    # Primary tailnet
    tailscale-primary = {
      image = "tailscale/tailscale:latest";
      volumes = [
        "/srv/tailscale-primary:/var/lib/tailscale"
        "/dev/net/tun:/dev/net/tun"
      ];
      environment = {
        TS_STATE_DIR = "/var/lib/tailscale";
        TS_EXTRA_ARGS = "--advertise-exit-node";
        TS_ACCEPT_DNS = "true";
      };
      extraOptions = [
        "--cap-add=NET_ADMIN"
        "--cap-add=NET_RAW"
        "--hostname=tailscale-primary"
      ];
      autoStart = true;
    };

    # Secondary tailnet — login manually via: sudo docker logs tailscale-secondary
    tailscale-secondary = {
      image = "tailscale/tailscale:latest";
      volumes = [
        "/srv/tailscale-secondary:/var/lib/tailscale"
        "/dev/net/tun:/dev/net/tun"
      ];
      environment = {
        TS_STATE_DIR = "/var/lib/tailscale";
        TS_EXTRA_ARGS = "--advertise-exit-node";
        TS_ACCEPT_DNS = "true";
      };
      extraOptions = [
        "--cap-add=NET_ADMIN"
        "--cap-add=NET_RAW"
        "--hostname=tailscale-secondary"
      ];
      autoStart = true;
    };
  };

  # Open Tailscale UDP port on the firewall
  networking.firewall.allowedUDPPorts = [ 41641 ];
}
