{ stdenv, buildGoModule, fetchzip, makeWrapper, go }:
let
  repo = "https://git.sr.ht/~sircmpwn/annotatego";
  rev = "bf211688254ff94c3221640925c4608e4738c9d1";
in
buildGoModule rec {
  name = "annotatego";

  src = fetchzip {
    url = "${repo}/archive/${rev}.tar.gz";
    sha256 = "0phhi7qvfsw0yzpys6vaa3anbgziwwj3zz6c8yh6jak6ngky6b7k";
  };

  getopt = fetchzip {
    url = "https://git.sr.ht/~sircmpwn/getopt/archive/292febf82fd04108e41c3ddf8948669d073267da.tar.gz";
    sha256 = "0jm50ja0pq1m3chhv21rp1mmwvadxinbyl1kdm73i7fyz3b1r2r6";
  };

  vendorSha256 = "0910zxyngi7cl9x51hhaw5wwlg2x1nmyf48anp7bmh9nryyb8bvy";

  overrideModAttrs = (_: {
    postBuild = ''
      cp -r --reflink=auto ${getopt} vendor/git.sr.ht/~sircmpwn/getopt
    '';
  });

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
