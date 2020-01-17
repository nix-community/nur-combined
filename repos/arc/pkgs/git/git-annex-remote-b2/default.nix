{ buildGoModule, fetchFromGitHub }: buildGoModule rec {
  pname = "git-annex-remote-b2";
  version = "2020-01-17-arc";

  src = fetchFromGitHub {
    owner = "arcnmx";
    repo = pname;
    rev = "d036ce90a51cddd5b7e7fbcf98e6b2a10f5aa64e";
    sha256 = "01gwmswj37qa19i4sdbap33zs8m0rz8il1wars18l40mh9a0c1rz";
  };

  modSha256 = "0565nvb6gq90i1ypv08rq41ivf04xqa3pw3hvl7208vdxzmn9ry2";
}
