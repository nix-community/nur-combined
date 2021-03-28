{ stdenv, fetchurl, fetchgit, fetchFromGitHub, git }:
let
  neatroffSrc = fetchFromGitHub {
    owner = "aligrudi";
    repo = "neatroff";

    rev="9c58dba3438cbf2497178b45a7f4c7cdc001a7f0";
    sha256="0hh7kcxkzjvqapzy2x8c042zafv1dwirc4rjpny2z0940gw2c8mh";
  };
  neatpostSrc = fetchFromGitHub {
    owner = "aligrudi";
    repo = "neatpost";
    rev = "14fafdadb05a2ea128a8aa3ce43ac2010f77c5e0";
    sha256 = "17vzr0zbh2d4i53zdnidd14lvblgp8drv3pzzxrwnkln4ri448nh";
  };
  neatmkfnSrc = fetchFromGitHub {
    owner = "aligrudi";
    repo = "neatmkfn";
    rev = "75c3ea970de97a857fc27c70696e5009ccf73e71";
    sha256 = "0yhsvwb3yyc852q3174ldx37mjj7171kbaxnq9p5nmjz265dw88a";
  };
  neateqnSrc = fetchFromGitHub {
    owner = "aligrudi";
    repo = "neateqn";
    rev = "227fa723d1e703f6424968c8c99809769e10165f";
    sha256 = "0ihp7rkfyz3pnlyi53w3rpa0k42791q71d618jz1l88pmfa00p9w";
  };
  neatreferSrc = fetchFromGitHub {
    owner = "aligrudi";
    repo = "neatrefer";
    rev = "b11d03d051f79791d03d6d3c1c9f492c1fa1f512";
    sha256 = "12g47nd3qbkfzr4cpchcsx4bh0g8wiqs6vzya2j4w18rqrzi3166";
  };
  troffSrc = fetchgit {
    url = "git://repo.or.cz/troff.git";
    rev = "8a83ad3156f499f2483b46c03d6c4770592fb335";
    sha256 = "16hcybn1y9byvw2cv2z7m3yhdwak5m69gnq0x6kq62vlify31jl3";
  };
  fonts = stdenv.mkDerivation {
    name = "neatroff-fonts";
    srcs = fetchFromGitHub {
        name = "urw";
        owner = "ArtifexSoftware";
        repo = "urw-base35-fonts";
        rev = "20170801.1";
        sha256 = "sha256:1k578r3qb0sjfd715jw0bc00pjvbrgnw0b7zrrhk33xghrdvp4r6";
    };

    installPhase = ''
      mkdir -p $out
      cp fonts/*.t1 $out
      cp fonts/*.afm $out
    '';
  };
in
  stdenv.mkDerivation {
    name = "neatroff";

    src = fetchFromGitHub {
      repo = "neatroff_make";
      owner = "aligrudi";
      rev = "beeb7df77be057ffb5a0c537cf6e26fd3387e1af";
      sha256 = "174pi6j3zgnk7yv37pi4jlnyc9pc2syc2fj0nzgimnkgcznyxp30";
    };

    nativeBuildInputs = [ git ];

    buildPhase = ''
      cp -r ${neatroffSrc} neatroff
      cp -r ${neatpostSrc} neatpost
      cp -r ${neatmkfnSrc} neatmkfn
      cp -r ${neateqnSrc} neateqn
      cp -r ${neatreferSrc} neatrefer
      cp -r ${troffSrc} troff
      cp ${fonts}/* fonts
      chmod u+w -R neat*
      chmod u+w -R troff
      cd neatroff
      patch -p1 < ${./format-security.patch}
      cd ..
      cd neateqn
      patch -p1 < ${./eqn-format-security.patch}
      cd ..
      echo
      echo
      echo
      ls -l fonts
      echo
      echo
      echo
      make neat BASE=$out
    '';

    installPhase = ''
      mkdir -p $out/bin
      make install BASE=$out
      ln -s $out/neatroff/roff $out/bin/roff
      ln -s $out/neatpost/post $out/bin/post
      ln -s $out/neatpost/pdf $out/bin/pdf
      ln -s $out/neateqn/eqn $out/bin/eqn
      ln -s $out/neatrefer/refer $out/bin/refer
      ln -s $out/troff/pic/pic $out/bin/pic
      ln -s $out/troff/tbl/tbl $out/bin/tbl
      ln -s $out/soin/soin $out/bin/soin
    '';
  }
