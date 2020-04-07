# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  secrets = import ./secrets.nix;
  all-hies = import (fetchTarball "https://github.com/infinisil/all-hies/tarball/master") {};
in
{
  disabledModules = [ "services/networking/zerotierone.nix" ];
  # boot.blacklistedKernelModules = [ "snd_pcsp" ];

  nixpkgs = {
    system = "x86_64-linux";
    overlays = [
      (import ./packages/overlay.nix { inherit secrets config; })
    ];
    config = {
      allowUnfree = true;
      allowBroken = true;
      permittedInsecurePackages = [
         "webkitgtk-2.4.11"
      ];
      firefox = {
        enableGoogleTalkPlugin = true;
        # enableAdobeFlash = true;
      };

      # chromium = {
        # enablePepperFlash = true; # Chromium's non-NSAPI alternative to Adobe Flash
      #   enablePepperPDF = true;
      # };
    };

  };
  imports =
    [
      ./desktop.nix
      ./cachix.nix
      ./packages/services.nix
      ./packages/zerotierone.nix
      ./multi-glibc-locale-paths.nix
    ];

  networking = {
    hosts = {
      "10.147.17.252" = [ "xps15" ];
      "10.147.17.21"  = [ "office" ];
    };
    firewall.allowPing = true;
    firewall.allowedTCPPorts = [
      8384 # syncthing ui
    ];
  };
  nix = {
    binaryCaches = [
      https://cache.nixos.org
      https://hie-nix.cachix.org
      https://cache.dhall-lang.org
    ];
    extraOptions = ''
      auto-optimise-store = true
    '';
    trustedBinaryCaches = [ https://hydra.nixos.org ];
    binaryCachePublicKeys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "hie-nix.cachix.org-1:EjBSHzF6VmDnzqlldGXbi0RM3HdjfTU3yDRi9Pd0jTY="
      "cache.dhall-lang.org:I9/H18WHd60olG5GsIjolp7CtepSgJmM2CsO813VTmM="
    ];
  };

  environment.variables."SSL_CERT_FILE" = "/etc/ssl/certs/ca-bundle.crt";
  environment.variables."GIT_SSL_CAINFO" = "/etc/ssl/certs/ca-certificates.crt";
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
    gcc
    gitAndTools.gitFull
    gitAndTools.tig
    gnome3.gnome-screenshot
    google-chrome
    gnumake
    (all-hies.selection { selector = p: { inherit (p) ghc864 ghc882; }; })
    haskellPackages.ghc
    haskellPackages.xmonad
    haskellPackages.xmonad
    haskellPackages.xmonad-contrib
    haskellPackages.xmonad-extras
    htop
    hugo
    iftop
    iotop
    iptables
    isync
    networkmanagerapplet
    msmtp
    mu
    nox
    oh-my-zsh
    pavucontrol
    perf-tools
    polkit_gnome
    pstree
    pwgen
    python27Packages.pygments
    s3cmd
    silver-searcher
    sqlite
    terminator
    texlive.combined.scheme-full
    unison
    w3m
    wget
  ];

  # Select internationalisation properties.
  i18n = {
    consoleFont = "lat9w-16";
    consoleKeyMap = "uk";
    defaultLocale = "en_GB.UTF-8";
  };

  hardware = {
    u2f.enable = true;
    pulseaudio = {
      enable = true;
      package = pkgs.pulseaudioFull;
    #   configFile = pkgs.writeText "default.pa" ''
    #     load-module module-bluetooth-policy
    #     load-module module-bluetooth-discover
    #     ## module fails to load with
    #     ##   module-bluez5-device.c: Failed to get device path from module arguments
    #     ##   module.c: Failed to load module "module-bluez5-device" (argument: ""): initialization failed.
    #     # load-module module-bluez5-device
    #     # load-module module-bluez5-discover
    #   '';
    };
  };

  # sound.enable = true;

  location = {
    latitude = 51.5072;
    longitude = 0.1275;
  };
  time.timeZone = "Europe/London";

  programs = {
    bash.enableCompletion = true;
    gnupg.agent = { enable = true; enableSSHSupport = true; };
    mtr.enable = true;
    # ssh.startAgent = true;
    zsh.enable = true;
  };

  services = {

    openssh.enable = true;
    locate.enable = true;
    fprintd.enable = true; # finger-print daemon and PAM module
    keybase.enable = true;

    # Might need this later
    # hercules-ci-agent.patchNix = true;

    acpid = {
      enable = true;
      powerEventCommands = ''
          systemctl suspend
        '';
    };

    # postgresql = {
    #   enable = true;
    #   enableTCPIP = true;
    #   package = pkgs.postgresql93;
    #   authentication = pkgs.lib.mkForce ''
    #     host     all    all    127.0.0.1/32    trust
    #     host     all    all    ::1/128         trust
    #     host     all    all    0.0.0.0/0       md5
    #     local    all    all                    trust
    #   '';
    #   extraConfig = ''
    #     maintenance_work_mem = 64MB
    #     checkpoint_segments = 16
    #     work_mem = 128MB
    #     shared_buffers = 512MB
    #     effective_cache_size = 4GB
    #     log_statement = all
    #     log_line_prefix = '[%p] [%c]: '
    #   '';
    #   # extraPlugins = [ pkgs.postgis.v_2_1_3 ];
    # };


    # # CUPS printing
    printing = {
      enable = true;
      drivers = [ pkgs.hplipWithPlugin ];
    };

    redshift = {
       enable = true;
       temperature = {
         night = 4000;
       };
     };

    syncthing = {
      enable = true;
      user = "ben";
      dataDir = "/home/ben/syncthing";
      openDefaultPorts = true;
    };

    # kubernetes = {
    #   roles = ["master" "node"];
    #   addonManager.enable = true;
    #   kubelet.extraOpts = "--fail-swap-on=false";
    #   flannel.enable = true;
    #   proxy.enable = true;
    #   addons = {
    #     dashboard.enable = true;
    #     # dashboard.rbac.enable = false;
    #     dns.enable = true;
    #   };
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
      roboto
      roboto-mono
      roboto-slab
      source-code-pro
      font-awesome-ttf
      siji
      fira
      fira-code
      fira-code-symbols
      fira-mono
      noto-fonts-emoji
      roboto
    ];
  };


  users.users.ben = {
    name = "ben";
    group = "users";
    extraGroups = [ "audio" "wheel" "vboxusers" "docker" "networkmanager" ];
    home = "/home/ben";
    shell = pkgs.zsh;
    symlinks = {
      # ".bashrc" = pkgs.bash-config;
      # ".zshrc" = pkgs.zsh-config;
      # ".background-image" = "${pkgs.nixos-artwork.wallpapers.gnome-dark}/share/artwork/gnome/nix-wallpaper-simple-dark-gray_bottom.png";
      ".mbsyncrc" = pkgs.email.mbsyncrc;
      ".msmtprc" = pkgs.email.msmtprc;
      ".notmuch-config" = pkgs.email.notmuch-config;
      # ".gitconfig" = pkgs.gitconfig;
      ".gnupg/gpg.conf" = pkgs.gnupgconfig.gpgconf;
      ".gnupg/scdaemon.conf" = pkgs.gnupgconfig.scdaemonconf;
      ".local/share/applications/org-protocol.desktop" = pkgs.spacemacs.orgProtocolDesktop;
      # ".spacemacs" = pkgs.spacemacs.dotSpacemacs;
   };
  };

  virtualisation = {
    docker.enable = true;
    docker.extraOptions = "--dns 8.8.8.8";
    virtualbox.host.enable = true;
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "18.03"; # Did you read the comment?

}
