# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

# from desktop


let
  secrets = import ./secrets.nix;
in
{
  imports =
    [
      ./hardware-configuration.nix
      ./common.nix
    ];

  boot.kernelPackages = pkgs.linuxPackages_testing;
  # # Use the systemd-boot EFI boot loader.
  boot.kernelParams = [ "acpi_rev_override=1" "pcie_aspm=off" "nouveau.modeset=0" ];
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  networking = {
    hostName = "xps15"; # Define your hostname.
    extraHosts = ''
      127.0.0.1 ${config.networking.hostName}
      10.147.17.21 office
    '';
    wireless.enable = false;
    enableIPv6 = false;
    # connman.enable = true;
    networkmanager.enable = true;

  };

  services = {
    # Required for our screen-lock-on-suspend functionality
    logind.extraConfig = ''
      LidSwitchIgnoreInhibited=False
      HandleLidSwitch=suspend
      HoldoffTimeoutSec=10
    '';

    xserver = {
      libinput = {
        enable = true;
        disableWhileTyping = true;
        naturalScrolling = false; # reverse scrolling
        scrollMethod = "twofinger";
        tapping = true;
        tappingDragLock = false;
      };
      synaptics.enable = false;
      deviceSection = ''
        Option "DRI" "3"
        Option "TearFree" "true"
      '';
      monitorSection = ''
        DisplaySize 406 228
      '';
    };

    actkbd.bindings = [
        { keys = [ 224 ]; events = [ "key" "rep" ]; command = "${pkgs.light}/bin/light -U 4"; }
        { keys = [ 225 ]; events = [ "key" "rep" ]; command = "${pkgs.light}/bin/light -A 4"; }
        { keys = [ 229 ]; events = [ "key" "rep" ]; command = "${pkgs.kbdlight}/bin/kbdlight down"; }
        { keys = [ 230 ]; events = [ "key" "rep" ]; command = "${pkgs.kbdlight}/bin/kbdlight up"; }
    ];

    acpid = {
      lidEventCommands = ''
          systemctl hibernate
        '';
    };
  };
}
