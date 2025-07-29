{ maintainers }:
if builtins.hasAttr "chrjabs" maintainers then
  maintainers.chrjabs
else
  {
    email = "contact@christophjabs.info";
    github = "chrjabs";
    githubId = 98587286;
    name = "Christoph Jabs";
    keys = [ { fingerprint = "47D6 1FEB CD86 F3EC D2E3  D68A 83D0 74F3 48B2 FD9D"; } ];
  }
