{ config, pkgs, expr, buildVM, ... }:

let
  iconTheme = pkgs.breeze-icons.out;
  themeEnv = ''
    # QT: remove local user overrides (for determinism, causes hard to find bugs)
    rm -f ~/.config/Trolltech.conf

    # GTK3: remove local user overrides (for determinisim, causes hard to find bugs)
    rm -f ~/.config/gtk-3.0/settings.ini

    # GTK3: add breeze theme to search path for themes
    # (currently, we need to use gnome-breeze because the GTK3 version of breeze is broken)
    export XDG_DATA_DIRS="${pkgs.gnome-breeze}/share:$XDG_DATA_DIRS"

    # GTK3: add /etc/xdg/gtk-3.0 to search path for settings.ini
    # We use /etc/xdg/gtk-3.0/settings.ini to set the icon and theme name for GTK 3
    export XDG_CONFIG_DIRS="/etc/xdg:$XDG_CONFIG_DIRS"

    # GTK2 theme + icon theme
    export GTK2_RC_FILES=${pkgs.writeText "iconrc" ''gtk-icon-theme-name="breeze"''}:${pkgs.breeze-gtk}/share/themes/Breeze/gtk-2.0/gtkrc:$GTK2_RC_FILES

    # SVG loader for pixbuf (needed for GTK svg icon themes)
    export GDK_PIXBUF_MODULE_FILE=$(echo ${pkgs.librsvg.out}/lib/gdk-pixbuf-2.0/*/loaders.cache)

    # LS colors
    eval `${pkgs.coreutils}/bin/dircolors "${./dircolors}"`
  '';

in {

imports = [];

nixpkgs.config = {
  packageOverrides = pkgs: rec {
    polybar = pkgs.polybar.override {
      # githubSupport = true; https://github.com/jaagr/polybar/issues/647
      alsaSupport = true;
      mpdSupport = true;
    };
  };
};

fonts = {
    enableFontDir = true;
    enableCoreFonts = true; # MS proprietary Core Fonts
    enableGhostscriptFonts = true;
    fonts = [
       pkgs.corefonts
       pkgs.ttf_bitstream_vera
       pkgs.vistafonts          # e.g. consolas
       pkgs.font-awesome-ttf    # needed by my i3 config!
       # pkgs.source-code-pro
    ];
    fontconfig = {
      enable = true;
      defaultFonts.monospace = [ "Consolas" ];
    };
  };

hardware.opengl.enable = false;

services.accounts-daemon.enable = true; # needed by lightdm

# Required for our screen-lock-on-suspend functionality
services.logind.extraConfig = ''
   LidSwitchIgnoreInhibited=False
   HandleLidSwitch=suspend
   HoldoffTimeoutSec=10
'';

# Enable the X11 windowing system.
services.xserver = {
  enable = true;
  # useGlamor = true;

  layout = "gb";
  autorun = true;
  exportConfiguration = true;

  # use the touch-pad for scrolling
  libinput = {
   enable = true;
   disableWhileTyping = true;
   naturalScrolling = false; # reverse scrolling
   scrollMethod = "twofinger";
   tapping = true;
   tappingDragLock = false;
  };

  # consensus is that libinput gives better results
  synaptics.enable = false;

  # config = ''
  #    Section "InputClass"
  #      Identifier     "Enable libinput for TrackPoint"
  #      MatchIsPointer "on"
  #      Driver         "libinput"
  #      Option         "ScrollMethod" "button"
  #      Option         "ScrollButton" "8"
  #    EndSection
  #  '';

  windowManager = {
    default = "xmonad";
    xmonad = {
      enable = true;
      enableContribAndExtras = true;
      extraPackages = haskellPackages: [
        haskellPackages.xmonad-contrib
        haskellPackages.xmonad-extras
        haskellPackages.xmonad
      ];
    };
  };

  desktopManager = {
    default = "gnome3";
    gnome3 = {
      enable = true;
    };
  };

  displayManager.lightdm = {
   enable = true;
   autoLogin = {
     enable = true;
     user = "ben";
   };
  };
  # videoDrivers = [ "nvidia" ];
  # videoDrivers = [ "nouveau" ];
  deviceSection = ''
    Option "DRI" "3"
    Option "TearFree" "true"
  '';
  monitorSection = ''
    DisplaySize 406 228
  ''; 

  displayManager.sessionCommands = ''
     ${pkgs.xlibs.xsetroot}/bin/xsetroot -cursor_name left_ptr

     ${pkgs.xlibs.xrdb}/bin/xrdb -merge ~/.Xresources
     # ${pkgs.xlibs.xrdb}/bin/xrdb -merge /etc/X11/Xresources

     [ -f ~/.Xmodmap ] && xmodmap ~/.Xmodmap

     # background image - nitrogen has better multihead support than feh
     ${pkgs.nitrogen}/bin/nitrogen --restore

     # Subscribes to the systemd events and invokes i3lock.
     # Send notification after 10 mins of inactivity,
     # lock the screen 10 seconds later.
     # TODO nixify xss-lock scripts
     ${pkgs.xlibs.xset}/bin/xset s 600 10
     ${pkgs.xss-lock}/bin/xss-lock -n ~/bin/lock-notify.sh -- ~/bin/lock.sh &

     # disable PC speaker beep
     # ${pkgs.xlibs.xset}/bin/xset -b

     # gpg-agent for X session
     gpg-connect-agent /bye
     GPG_TTY=$(tty)
     export GPG_TTY

     # use gpg-agent for SSH
     # NOTE: make sure enable-ssh-support is included in ~/.gnupg/gpg-agent.conf
     unset SSH_AGENT_PID
     export SSH_AUTH_SOCK="/run/user/1000/gnupg/S.gpg-agent.ssh"
  '';
};

environment.extraInit = ''
  ${themeEnv}

  # these are the defaults, but some applications are buggy so we set them
  # here anyway
  export XDG_CONFIG_HOME=$HOME/.config
  export XDG_DATA_HOME=$HOME/.local/share
  export XDG_CACHE_HOME=$HOME/.cache
'';

# QT4/5 global theme
environment.etc."xdg/Trolltech.conf" = {
  text = ''
    [Qt]
    style=Breeze
  '';
  mode = "444";
};

# GTK3 global theme (widget and icon theme)
environment.etc."xdg/gtk-3.0/settings.ini" = {
  text = ''
    [Settings]
    gtk-icon-theme-name=breeze
    gtk-theme-name=Breeze-gtk
  '';
  mode = "444";
};

environment.systemPackages = with pkgs; [
  dmenu
  dunst
  fontconfig
  konsole
  polybar
  libnotify
  xfontsel
  xclip
  xss-lock
  xsel
  unclutter

  compton
  nitrogen # better multihead support than feh
  pinentry_qt4

  xlibs.xbacklight
  xlibs.xmodmap
  xlibs.xev
  xlibs.xinput
  xlibs.xmessage
  xlibs.xkill
  xlibs.xgamma
  xlibs.xset
  xlibs.xrandr
  xlibs.xrdb
  xlibs.xprop

  # # GTK theme
  breeze-gtk
  gnome-breeze
  gnome3.gnome_themes_standard

  # # Qt theme
  breeze-qt5

  # # Icons (Main)
  iconTheme

  # # Icons (Fallback)
  oxygen-icons5
  gnome3.adwaita-icon-theme
  hicolor_icon_theme

  # These packages are used in autostart, they need to in systemPackages
  # or icons won't work correctly
  pythonPackages.udiskie connman-notify # skype

];

# needed by mendeley
# services.dbus.packages = [ pkgs.gnome3.gconf.out ];

# Make applications find files in <prefix>/share
environment.pathsToLink = [ "/share" "/etc/gconf" ];

services.udev = {
    packages = [ pkgs.libmtp ];
    extraHwdb = ''
      evdev:atkbd:dmi:*
        KEYBOARD_KEY_121=mute
        KEYBOARD_KEY_122=volumedown
        KEYBOARD_KEY_123=volumeup
    '';
 };
sound.mediaKeys.enable = true;
services.actkbd.bindings = [
    { keys = [ 224 ]; events = [ "key" "rep" ]; command = "${pkgs.light}/bin/light -U 4"; }
    { keys = [ 225 ]; events = [ "key" "rep" ]; command = "${pkgs.light}/bin/light -A 4"; }
    { keys = [ 229 ]; events = [ "key" "rep" ]; command = "${pkgs.kbdlight}/bin/kbdlight down"; }
    { keys = [ 230 ]; events = [ "key" "rep" ]; command = "${pkgs.kbdlight}/bin/kbdlight up"; }
  ];

}
