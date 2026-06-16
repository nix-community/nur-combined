{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:
let
  version = "1.9.0";
in
buildGoModule {
  pname = "dir2opds";
  inherit version;

  src = fetchFromGitHub {
    owner = "dubyte";
    repo = "dir2opds";
    rev = "v${version}";
    hash = "sha1-OJ1ll7IL8Ci6gCYi8myD55jqWFg=";
  };

  vendorHash = "sha1-Dnz5wgWQrcPLkoELXJlYKV09W20=";

  meta = with lib; {
    homepage = "https://github.com/dubyte/dir2opds";
    description = "Serve an OPDS based on a directory";
    license = licenses.gpl3;
    mainProgram = "dir2opds";
  };
}
