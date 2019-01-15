{ pkgs }:

pkgs.hydra.overrideAttrs (_: rec {
  name    = "hydra-${version}";
  version = "2018-10-15";
  patchs  = [ ./hydra-no-restricteval.diff ];
  src     = pkgs.fetchFromGitHub {
    owner   = "kreisys";
    repo    = "hydra";
    rev     = "e0f204f3da6245fbaf5cb9ef59568b775ddcb929";
    sha256  = "039s5j4dixf9xhrakxa349lwkfwd2l9sdds0j646k9w32659di61";
  };
})
