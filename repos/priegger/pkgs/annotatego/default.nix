{ stdenv, buildGoModule, fetchzip, makeWrapper, go }:
let
  repo = "https://git.sr.ht/~sircmpwn/annotatego";
  rev = "bf211688254ff94c3221640925c4608e4738c9d1";
in
buildGoModule {
  name = "annotatego";

  src = fetchzip {
    url = "${repo}/archive/${rev}.tar.gz";
    sha256 = "0phhi7qvfsw0yzpys6vaa3anbgziwwj3zz6c8yh6jak6ngky6b7k";
  };

  modSha256 = "1qszxz7wpbb664h6a9imqyc3zasyigygb409r1lll741mk43ndrx";

  nativeBuildInputs = [ makeWrapper ];

  allowGoReference = true;
  postInstall = ''
    wrapProgram $out/bin/annotatego \
      --prefix PATH : ${ stdenv.lib.makeBinPath [ go ] }
  '';

  meta = with stdenv.lib; {
    description = "Creates sourcehut JSON annotations for Go source trees";
    homepage = repo;
    license = licenses.lgpl3;
  };
}
