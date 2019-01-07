{ config, emacs, mutate, mu, isync, msmtp, w3m }:
{
  dotSpacemacs = mutate ./spacemacs {
    inherit mu isync msmtp w3m; fontSize = config.programs.spacemacsFontSize;
  };

  orgProtocolDesktop = mutate ./org-protocol.desktop { inherit emacs; };

}
