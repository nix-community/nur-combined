# Used directly by nixpkgs' mariokart64recomp in place of requireFile.
{ fetchurl }:
fetchurl {
  name = "mk64.us.z64";
  url = "https://raw.githubusercontent.com/TheGodlyTree/Mario-Kart-64/6ef4df85323947036303c2f68a5516bb253f3bbd/Mario%20Kart%2064%20%28USA%29.z64";
  hash = "sha256-1rhTjdY/ATLssoVufTKBbtPDDj5HmuzSPPg/troXpdo=";
}
