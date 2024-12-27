{ self
}:
{
  # Add your NixOS modules here
  #
  linguee-api = import ./linguee-api { inherit self; };
}
