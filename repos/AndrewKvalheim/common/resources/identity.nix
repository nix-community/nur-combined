let
  inherit (builtins) readFile;
in
{
  name.long = "Andrew Kvalheim";
  name.short = "Andrew";
  username = "ak";
  email = "andrew@kvalhe.im";
  openpgp.id = "0x9254D45940949194";
  openpgp.asc = ./andrew.asc;
  phone = "+1-206-499-0693";
  ssh = readFile ./andrew.pub;
  image = ./andrew.jpg;
}
