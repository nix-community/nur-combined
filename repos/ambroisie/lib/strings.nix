{ ... }:
let
in
{
  # Make an email address from the name and domain stems
  #
  # mkMailAddress :: String -> String -> String
  mkMailAddress = name: domain: "${name}@${domain}";
}
