{ buildGoModule, fetchFromGitHub, lib}:
buildGoModule rec {
  name = "efm-langserver";
  version = "0.0.10";
  src = fetchFromGitHub {
    owner = "mattn";
    repo = "efm-langserver";
    rev = "v${version}";
    sha256 = "1bcfyna4dkwid7kpla9f9798lyg92n54rbkf5f909c9wj8ss3xwa";
  };
  modSha256 = "027v8b88i5dab0pbgv2mwk1k0ll8781lkcip8dd8gl7mpqjbwlzz";
  subPackages = ["."];

  meta = with lib; {
    description = "General purpose Language Server";
    homepage = https://github.com/mattn/efm-langserver;
    license = licenses.mit;
    platforms = platforms.linux ++ platforms.darwin;
  };
}

