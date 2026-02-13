{ config, pkgs, lib, ... }:

{
  # Add a second Tailscale container for joining an additional tailnet.
  # The primary Tailscale container is defined in the home-assistant role.
  # Login manually via: sudo docker logs tailscale-secondary

  # Persistent state directory for the secondary instance
  systemd.tmpfiles.rules = [
    "d /srv/tailscale-secondary 0700 root root -"
  ];

  virtualisation.oci-containers.containers = {
    tailscale-secondary = {
      image = "tailscale/tailscale:latest";
      volumes = [
        "/srv/tailscale-secondary:/var/lib/tailscale"
        "/dev/net/tun:/dev/net/tun"
      ];
      environment = {
        TS_STATE_DIR = "/var/lib/tailscale";
        TS_EXTRA_ARGS = "--advertise-exit-node --port=41642";
        TS_ACCEPT_DNS = "true";
        TS_HOSTNAME = config.networking.hostName;
      };
      extraOptions = [
        "--cap-add=NET_ADMIN"
        "--cap-add=NET_RAW"
        "--network=host"
      ];
      autoStart = true;
    };
  };
}
