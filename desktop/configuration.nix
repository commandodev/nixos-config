# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{

  programs.spacemacsFontSize = 12;

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
      10.147.17.252 xps15
    '';
    hostName = "office"; # Define your hostname.
    useDHCP = true;
    # nameservers = [ "8.8.8.8" "192.168.0.1" ];
    networkmanager.enable = false;
    firewall.allowedTCPPorts = [ 2003 3000 8005 8080 22 443 80 445 139 631 ];
    firewall.allowedUDPPorts = [ 2003 137 138 631 ];
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

    syncthing.guiAddress = "10.147.17.21:8384";

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
