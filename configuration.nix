# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      <nixpkgs/nixos/modules/profiles/all-hardware.nix>
      ./desktop.nix
    ];

  hardware.cpu.intel.updateMicrocode = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Use the systemd-boot EFI boot loader.
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
    efi.efiSysMountPoint = "/boot";
    grub.device = "nodev";
    grub.enable = true;
    grub.efiSupport = true;
    #grub.efiInstallAsRemovable = true;
    grub.fsIdentifier = "uuid";
    grub.gfxmodeEfi = "auto";
    grub.version = 2;
  };
  networking = {
    hostName = "xps15"; # Define your hostname.
    wireless.enable = false;
    enableIPv6 = false;
    # connman.enable = true;
    networkmanager.enable = true;

  };


  environment.systemPackages = with pkgs; [
    acpi
    acpid
    aspell
    aspellDicts.en
    bc
    bmon # simple bandwidth monitor and rate estimator
    bzip2
    cdparanoia
    chromium
    colordiff
    coreutils
    cpio
    cpufrequtils
    curl
    dbus
    diffstat
    diffutils
    dmenu
    docker
    dos2unix
    emacs
    evince
    firefox
    fish
    gitAndTools.gitFull
    gitAndTools.tig
    haskellPackages.ghc
    haskellPackages.xmonad
    haskellPackages.xmonad
    haskellPackages.xmonad-contrib
    haskellPackages.xmonad-extras
    htop
    iftop
    iotop
    iptables
    networkmanagerapplet
    nix-repl
    nox
    oh-my-zsh
    perf-tools
    polkit_gnome
    pwgen
    s3cmd
    silver-searcher
    terminator
    unison
    wget
  ];

  # Select internationalisation properties.
  # i18n = {
  #   consoleFont = "Lat2-Terminus16";
  #   consoleKeyMap = "us";
  #   defaultLocale = "en_US.UTF-8";
  # };
  nixpkgs.config = {
    allowUnfree = true;
    allowBroken = true;
    firefox = {
      enableGoogleTalkPlugin = true;
      enableAdobeFlash = true;
    };

    chromium = {
      enablePepperFlash = true; # Chromium's non-NSAPI alternative to Adobe Flash
      enablePepperPDF = true;
    };
   };

  time.timeZone = "Europe/London";


  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.bash.enableCompletion = true;
  # programs.mtr.enable = true;
  # programs.gnupg.agent = { enable = true; enableSSHSupport = true; };


  services = {
    acpid = {
      enable = true;
      powerEventCommands = ''
          systemctl suspend
        '';
      lidEventCommands = ''
          systemctl hibernate
        '';
    };

    # CUPS printing
    printing = {
      enable = true;
      drivers = [ pkgs.hplipWithPlugin ];
    };

    redshift = {
       enable = true;
       latitude = "51.5072";
       longitude = "0.1275";
       temperature = {
         night = 4000;
       };
     };
    compton = {
      enable = true;
      fade = true;
    };

    locate.enable = true;
    fprintd.enable = true; # finger-print daemon and PAM module

    syncthing = {
      enable = false;
      user = "ben";
      dataDir = "/home/ben/syncthing";
    };

    # apache-kafka = {
    #   enable = false;
    #   brokerId = 1;
    # };

    # zookeeper = {
    #   enable = false;
    # };
  };


  fonts = {
    enableFontDir = true;
    enableGhostscriptFonts = true;
    fonts = with pkgs; [
      corefonts  # Micrsoft free fonts
      inconsolata  # monospaced
      ubuntu_font_family  # Ubuntu fonts
      source-code-pro
      font-awesome-ttf
      siji
    ];
  };


  users.extraUsers.ben = {
    name = "ben";
    group = "users";
    extraGroups = [ "wheel" "vboxusers" "docker" "networkmanager" ];
    home = "/home/ben";
    shell = pkgs.zsh;
   };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  # users.extraUsers.guest = {
  #   isNormalUser = true;
  #   uid = 1000;
  # };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "18.03"; # Did you read the comment?
  

}
