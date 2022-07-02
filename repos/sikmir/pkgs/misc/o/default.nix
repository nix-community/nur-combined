{ lib, buildGoModule, fetchFromGitHub, installShellFiles }:

buildGoModule rec {
  pname = "o";
  version = "2.53.0";

  src = fetchFromGitHub {
    owner = "xyproto";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-3tr0q/0xw/NHvicrY0ZB+7A1isSDVZhcuFpzFadW7Js=";
  };

  vendorSha256 = null;

  nativeBuildInputs = [ installShellFiles ];

  preBuild = "cd v2";

  postInstall = ''
    installManPage ../o.1
  '';

  meta = with lib; {
    description = "Config-free text editor and IDE limited to VT100";
    inherit (src.meta) homepage;
    license = licenses.bsd3;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
