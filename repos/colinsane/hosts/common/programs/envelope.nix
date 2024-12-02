# Envelope is a GTK4 email client (alpha). as of 2024-10-13 it:
# - supports viewing emails, including HTML
# - supports clicking links
# - DOESN'T support writing mail
# - DOESN'T support working with more than one account
# - DOESN'T support marking mail as read
#
# in terms of implementation, passwords are stored in the gnome keyring
{ ... }:
{
  sane.programs.envelope = {
    buildCost = 2;  #< webkitgtk-6_0
    sandbox.method = null;  #< TODO
    # config has to be edited by hand, by reading the structure of the Rust data types
    secrets.".config/envelope/config.json" = ../../../secrets/common/envelope_config.json.bin;
  };
}
