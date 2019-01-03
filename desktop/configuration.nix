# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ./common.nix
    ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  # Define on which hard drive you want to install Grub.
  boot.loader.grub.device = "/dev/sda";

  networking = {
    extraHosts = ''
      127.0.0.1 ${config.networking.hostName}
    '';
    hostName = "office"; # Define your hostname.
    useDHCP = true;
    # nameservers = [ "8.8.8.8" "192.168.0.1" ];
    # networkmanager.enable = true;
    firewall.allowPing = true;
    firewall.allowedTCPPorts = [ 2003 3000 8005 8080 22 443 80 445 139 631];
    firewall.allowedUDPPorts = [ 2003 137 138 631];
  };

  # Select internationalisation properties.

  nix = {
    extraOptions = ''
      build-cores = 8
    '';
  };

  services = {

    postfix = {
      enable = true;
      setSendmail = true;
    };

    statsd = {
      enable = true;
      backends = ["graphite"];
      graphiteHost = "127.0.0.1";
      graphitePort = 2003;
    };

    graphite = {
      api = {
        enable = true;
      };
      web = {
        enable = true;
        port = 8082;
      };
      carbon = {
        enableCache = true;
      };
    };

    grafana = {
      enable = true;
      auth.anonymous.enable = true;
    };

    elasticsearch = {
      enable = true;
    };

    kibana = {
      enable = true;
    };

    riemann = {
      enable = true;
      config = ''
      (let [host "0.0.0.0"]
        (tcp-server {:host host})
        (udp-server {:host host})
        (ws-server {:host host})
        (sse-server {:host host}))
      (let [index (index)]
         (streams index))
      '';
    };
    riemann-dash = {
      enable = true;
      config = ''
      '';
    };

    journalbeat = {
      enable = false;
      extraConfig = ''
        journalbeat:
           seek_position: cursor
           cursor_seek_fallback: tail
           write_cursor_state: true
           cursor_flush_period: 5s
           clean_field_names: true
           convert_to_numbers: false
           move_metadata_to_field: journal
           default_type: journal
         output:
           elasticsearch:
             enabled: true
             hosts: ["localhost:9200"]
      '';
    };
    gocd-server = {
      enable = true;
      extraOptions = [ "-Dgo.plugin.upload.enabled=true"
                       "-DpluginLocationMonitor.sleepTimeInSecs=3"
                     ];
    };

    gocd-agent = {
      enable = true;
      packages = [ pkgs.stdenv pkgs.jre pkgs.git config.programs.ssh.package
                   pkgs.nix pkgs.docker pkgs.stack pkgs.postgresql
                 ];

      extraGroups = [ "docker" "users" ];
    };
    # enable tcp forwarding
    lshd.tcpForwarding = true;

    # hydra = {
    #   enable = true;
    #   dbi = "dbi:Pg:dbname=hydra;host=localhost;user=hydra;";
    #   hydraURL = "http://hydra.perurbis.com/";
    #   listenHost = "localhost";
    #   package = (import "/home/ben/dev/hydra/release.nix" {}).build.x86_64-linux;
    #   port = 3000;
    #   minimumDiskFree = 5;  # in GB
    #   minimumDiskFreeEvaluator = 2;
    #   notificationSender = "hydra@perurbis.com";
    #   logo = null;
    #   debugServer = false;
    # };

  };
}
