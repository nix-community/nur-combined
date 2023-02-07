let
  primaryWirelessKey =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFZl+B55kdAs3wZv8W2O0wy2mNuJv9MD7Y+Do9IGSf9q";
  secondaryWirelessKey =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF0KzuSlDoE1jkiGfhVI5/N1rbmpUjQCLmpprcQMr+NW  ";
  wirelessKeys = [ primaryWirelessKey secondaryWirelessKey ];
in {
  # Wireless Secret keys
  "wireless-iot.env.age".publicKeys = wirelessKeys;
}
