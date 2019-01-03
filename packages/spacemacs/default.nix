{ config, mutate, mu, isync }:
{
  dotSpacemacs = mutate ./spacemacs {
    inherit mu isync; fontSize = config.programs.spacemacsFontSize;
  };
}
