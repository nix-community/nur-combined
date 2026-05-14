{ lib }:

let
  inherit (builtins) readFile;
  inherit (import ../library/utilities.lib.nix { inherit lib; }) frame sgr;
in
rec {
  name.long = "Andrew Kvalheim";
  name.short = "Andrew";
  username = "ak";
  email = "andrew@kvalhe.im";
  openpgp.id = "0x9254D45940949194";
  openpgp.asc = ./assets/andrew.asc;
  phone = "+1-206-499-0693";
  ssh = readFile ./assets/andrew.pub;
  image = ./assets/andrew.jpg;

  contactNotice = with sgr; frame magenta ''
    ${magenta "If found, please contact:"}

      ${blue "Name:"} ${name.long}
     ${blue "Email:"} ${email}
     ${blue "Phone:"} ${phone}
  '';
}
