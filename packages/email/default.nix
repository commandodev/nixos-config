{ mutate, gnupg, coreutils, notmuch, isync, findutils, gnused,
  gnugrep, lastpass-cli, lib, timeout_tcl }:
{
  mbsyncrc = mutate ./mbsyncrc {
    lpCli = lastpass-cli;
  };

  msmtprc = mutate ./msmtprc {
    lpCli = lastpass-cli;
  };

  notmuch-config = mutate ./notmuch-config {
    inherit gnupg;
  };

  pre-new = mutate ./pre-new.sh {
    inherit isync timeout_tcl;
  };

  post-new = mutate ./post-new.sh {
    path = lib.makeBinPath [
      coreutils notmuch isync findutils gnused gnugrep
    ];
  };
}
