{ fetchFromGitLab
, lib
, rustPlatform
}:
rustPlatform.buildRustPackage rec {
  pname = "xr";
  version = "0.1.0-20240308-679298be";
  src = fetchFromGitLab {
    owner = "agvallejo";
    repo = "rxen";
    rev = "679298beaab8578adbf40aab58a2178ed63c41d3";
    hash = "sha256-IpWs2E/piucGp9a5V5tm8Q2txVD8l/1DV3SX61jQcQ4=";
  };
  sourceRoot = "${src.name}/xr";

  cargoPatches = [
    ./update-cargo-lock.patch
  ];
  cargoHash = "sha256-ZYwkp+iNVsU0olhjfv54uaacjpXGTCLZQClnqYVLvds=";

  meta = with lib; {
    broken = versionOlder lib.version "24.05"; # xr depends on rustc 1.74, which is not present in 23.11
    description = "CLI utility for Xen state manipulation";
    longDescription = ''
      It's a rewrite of the logic currently present in `xl` and everything it
      links against. `xr` is meant to be able to fully replace `xl` through a
      compatibility switch, such that it can be seemlessly integrated
      into existing systems through an alias, such as `alias xl="xr xl"`.
    '';
    homepage = "https://gitlab.com/agvallejo/rxen";
    maintainers = with maintainers; [ javimerino ];
    license = [ licenses.unlicense ];
  };
}
