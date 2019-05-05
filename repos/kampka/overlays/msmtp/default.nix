self: super: {
  msmtp = builtins.trace "msmtp overlay" super.msmtp
    .overrideAttrs (old: {

    configureFlags = [ "--sysconfdir=/etc" ] ;
  });
}
