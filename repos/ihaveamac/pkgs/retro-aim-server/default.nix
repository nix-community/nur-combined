{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "retro-aim-server";
  version = "0.20.0";

  src = fetchFromGitHub {
    owner = "mk6i";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-+QpNzbphSOzbqPjdpjghYqSiLV93FPjrLsK8GTAlZUQ=";
  };

  vendorHash = "sha256-dGhoEppDZpzkgJQJnq4jhGDQNszqgnbb2P+JAccHLF8=";

  meta = with lib; {
    description = "Self-hostable instant messaging server compatible with classic AIM and ICQ clients";
    homepage = "https://github.com/mk6i/retro-aim-server";
    license = licenses.mit;
    platforms = platforms.all;
  };
}
