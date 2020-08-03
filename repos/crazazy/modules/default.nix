{
  # list of modules for NUR
  desktop-config = import ./desktop-configuration;
  packages-config = import ./packages-configuration;
  steam-config = import ./steam-configuration;
  system-config = import ./system-configuration;
  users-config = import ./users-configuration;
  vim-config = import ./vim-configuration;

  # separate usable modules
  feh-bg-module = import ./internet-background;
}
