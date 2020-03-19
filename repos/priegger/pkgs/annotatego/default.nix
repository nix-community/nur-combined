{ stdenv, buildGoModule, fetchzip, makeWrapper, go }:
let
  repo = "https://git.sr.ht/~sircmpwn/annotatego";
  rev = "e52c42dbbe89fcf4f615762423ba6dc347f333c0";
in
buildGoModule {
  name = "annotatego";

  src = fetchzip {
    url = "${repo}/archive/${rev}.tar.gz";
    sha256 = "0330xslgz6b1h3r2bjwbz3wv60rkh38wp4hnc8fzpk45k11m099d";
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
