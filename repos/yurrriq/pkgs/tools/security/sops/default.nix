{ stdenv, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "sops";
  version = "3.4.0";

  src = fetchFromGitHub {
    rev = version;
    owner = "mozilla";
    repo = pname;
    sha256 = "1mrqf9xgv88v919x7gz9l1x70xwvp6cfz3zp9ip1nj2pzn6ixz3d";
  };

  modSha256 = "1mcyshxnn0hzzrvclxciwmkwsp9b2qda0a6k643xm69km21rfavn";

  meta = with stdenv.lib; {
    homepage = "https://github.com/mozilla/sops";
    description = "Mozilla sops (Secrets OPerationS) is an editor of encrypted files";
    maintainers = [ maintainers.marsam ];
    license = licenses.mpl20;
  };
}
