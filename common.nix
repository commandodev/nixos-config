# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  secrets = import ./secrets.nix;
in
{
  disabledModules = [ "services/networking/zerotierone.nix" ];
  imports =
    [
      ./desktop.nix
      ./packages/zerotierone.nix
    ];

  nix = {
    binaryCaches = [ http://hydra.iohk.io http://cache.nixos.org http://hydra.nixos.org ];
    extraOptions = ''
      build-cores = 8
      auto-optimise-store = true
    '';
    trustedBinaryCaches = [ http://hydra.iohk.io http://hydra.nixos.org ];
    binaryCachePublicKeys = [
      "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ=" "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    ];
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
      # enableAdobeFlash = true;
    };

    chromium = {
      # enablePepperFlash = true; # Chromium's non-NSAPI alternative to Adobe Flash
      enablePepperPDF = true;
    };
   };

  time.timeZone = "Europe/London";


  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.bash.enableCompletion = true;
  programs.mtr.enable = true;
  programs.gnupg.agent = { enable = true; enableSSHSupport = true; };


  services = {

    acpid = {
      enable = true;
      powerEventCommands = ''
          systemctl suspend
        '';
    };

    # # CUPS printing
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
    # compton = {
    #   enable = true;
    #   fade = true;
    # };

    openssh.enable = true;
    locate.enable = true;
    fprintd.enable = true; # finger-print daemon and PAM module

    syncthing = {
      enable = true;
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
    zerotierone = {
      enable = true;
      package = pkgs.callPackage "/home/ben/dev/nixpkgs/pkgs/tools/networking/zerotierone" {};
      joinNetworks = secrets.ztNetworks;
    };
  };


  fonts = {
    enableFontDir = true;
    enableGhostscriptFonts = true;
    fonts = with pkgs; [
      # corefonts  # Micrsoft free fonts
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


  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "18.03"; # Did you read the comment?

}
