{ fetchFromGitHub }: rec {
  pname = "popcorntime";
  version = "0.4.4";
  name = "${pname}-${version}";
  src = fetchFromGitHub {
    owner = "popcorn-official";
    repo = "popcorn-desktop";
    rev = "v${version}";
    sha256 = "11difp6gjj8l21jhmjdx7a01g67n4s578ydll17s33jv4kpsbxf9";
  };
}
