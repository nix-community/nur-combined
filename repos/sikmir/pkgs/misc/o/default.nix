{ lib, buildGoModule, fetchFromGitHub, installShellFiles, makeWrapper, pkg-config, vte }:

buildGoModule rec {
  pname = "o";
  version = "2.55.0";

  src = fetchFromGitHub {
    owner = "xyproto";
    repo = "o";
    rev = "v${version}";
    hash = "sha256-AWRR/plPgOV6MoZnZYpQpeG2WLrzZNckDtK6BrEehtc=";
  };

  vendorSha256 = null;

  nativeBuildInputs = [ installShellFiles makeWrapper pkg-config ];

  buildInputs = [ vte ];

  preBuild = "cd v2";

  postInstall = ''
    cd ..
    installManPage o.1
    make install-gui PREFIX=$out
    wrapProgram $out/bin/ko --prefix PATH : $out/bin
  '';

  meta = with lib; {
    description = "Config-free text editor and IDE limited to VT100";
    inherit (src.meta) homepage;
    license = licenses.bsd3;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
