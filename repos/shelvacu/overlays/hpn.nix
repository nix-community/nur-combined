new: old: {
  openssh_no_hpn = old.openssh_no_hpn or old.openssh;
  openssh = new.openssh_hpn;
}
