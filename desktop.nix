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

fonts = {
    enableFontDir = true;
    enableGhostscriptFonts = true;
    fonts = [
       pkgs.corefonts
       pkgs.font-awesome-ttf    # needed by my i3 config!
       pkgs.inconsolata
       pkgs.ttf_bitstream_vera
       pkgs.ubuntu_font_family  # Ubuntu fonts
       pkgs.ubuntu_font_family  # Ubuntu fonts
       pkgs.vistafonts          # e.g. consolas
       # pkgs.source-code-pro
    ];
    fontconfig = {
      enable = true;
      dpi = 210;
      defaultFonts.monospace = [ "Consolas" ];
    };
  };

services.accounts-daemon.enable = true; # needed by lightdm

hardware.opengl.driSupport32Bit = true;

# Enable the X11 windowing system.
services.xserver = {
  enable = true;
  useGlamor = true;
  layout = "gb";
  autorun = true;
  exportConfiguration = true;
  xkbOptions = "eurosign:e";
  # videoDrivers = [ "nvidia" ];
  windowManager = {
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
    xfce.enable = false;
    # xfce.noDesktop = true;
    xfce.enableXfwm = false;
    gnome3 = {
      enable = true;
    };
  };

  displayManager = {
    defaultSession = "none+xmonad";
    lightdm = {
      enable = true;
      autoLogin = {
        enable = true;
        user = "ben";
        timeout = 10;
      };
      # autoLogin.timeout = 10;
      greeters.gtk.cursorTheme = {
        name = "Vanilla-DMZ";
        package = pkgs.vanilla-dmz;
        size = 64;
      };
  };
  # videoDrivers = [ "nouveau" ];

    sessionCommands = ''
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
  rofi
  polybar
  libnotify
  xfontsel
  xclip
  xss-lock
  xsel
  unclutter
  zoom-us

  ffmpeg-full
  gphoto2
  obs-studio

  compton
  nitrogen # better multihead support than feh

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

  # desktop apps
  nixnote2

  # # GTK theme
  breeze-gtk
  gnome-breeze
  gnome3.gnome_themes_standard

  # # Qt theme
  breeze-qt5

  # # Icons (Main)
  iconTheme
  xfce.xfwm4-themes
  xfce.xfce4-cpufreq-plugin
  xfce.xfce4-cpugraph-plugin
  # # Icons (Fallback)
  paper-gtk-theme
  paper-icon-theme
  adapta-gtk-theme
  numix-gtk-theme
  numix-solarized-gtk-theme
  adapta-backgrounds
  oxygen-icons5
  gnome3.adwaita-icon-theme
  hicolor_icon_theme

  # These packages are used in autostart, they need to in systemPackages
  # or icons won't work correctly
  # pythonPackages.udiskie
  connman-notify # skype

  steam
  steam-run-native

];

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
}
