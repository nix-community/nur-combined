{ lib, buildGoModule, fetchFromGitHub, makeWrapper, sources }:

buildGoModule rec {
  pname = "git-get";
  version = builtins.substring 0 7 src.rev;

  src = fetchFromGitHub {
    owner = "grdl";
    repo = "git-get";
    rev = sources.git-get.rev;
    sha256 = sources.git-get.sha256;
  };

  nativeBuildInputs = [ makeWrapper ];

  vendorSha256 = "05k6w4knk7fdjm9qm272nlrk47rzjr18g0fp4j57f5ncq26cxr8b";

  doCheck = false;

  postInstall = ''
    mkdir -p $out/bin
    wrapProgram $out/bin/get
    wrapProgram $out/bin/list
    mv $out/bin/get  $out/bin/git-get 
    mv $out/bin/list $out/bin/git-list
  '';

  meta = with lib; {
    inherit (sources.gralc) description homepage;
    license = licenses.mit;
    platforms = platforms.all;
  };
}
