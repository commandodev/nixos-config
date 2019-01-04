{ config, mutate, mu, isync, msmtp }:
{
  dotSpacemacs = mutate ./spacemacs {
    inherit mu isync msmtp; fontSize = config.programs.spacemacsFontSize;
  };
}
