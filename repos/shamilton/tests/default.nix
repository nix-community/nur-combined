{ nixpkgs ? <nixpkgs>
, pkgs ? import nixpkgs { }
, selfnur
, modules
}:
let
  home-manager = pkgs.fetchFromGitHub {
    owner = "nix-community";
    repo = "home-manager";
    rev = "4a3d01fb53f52ac83194081272795aa4612c2381";
    sha256 = "sha256-Nlnm4jeQWEGjYrE6hxi/7HYHjBSZ/E0RtjCYifnNsWk=";
  };
  callTest = t: t.test;
  hmTest = p: hm-module-test: 
    (import p {
      inherit modules hm-module-test;
    }) {
      inherit home-manager pkgs nixpkgs;
    };
  handleHmTest = p: hm-module-test:
    callTest ((hmTest p hm-module-test) {});
  handleTest = p: args:
    callTest ((import p args) {});
in rec {
  sync-database = handleTest ./sync-database.nix {
    inherit modules home-manager nixpkgs pkgs;
    inherit (selfnur) sync-database android-platform-tools;
  };
  # unoconvservice = handleTest ./unoconvservice.nix {
  #   inherit modules home-manager nixpkgs pkgs;
  # };
  hm-module-test = import ./hm-module-test.nix;
  myvim = handleHmTest ./myvim.nix hm-module-test;
  day-night-plasma-wallpapers =
    handleHmTest ./day-night-plasma-wallpapers.nix hm-module-test;
  redshift-auto = handleHmTest ./redshift-auto.nix hm-module-test;
  pronotebot = handleHmTest ./pronotebot.nix hm-module-test;
  pronote-timetable-fetch =
    handleHmTest ./pronote-timetable-fetch.nix hm-module-test;
}

