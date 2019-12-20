{ stdenv
, lib
, fetchFromGitLab
, fetchFromGitHub
#, fetchgit
, libbsd
# , lua
# , cjson # lua cjson TODO: Using bundled?
# , lua-readline TODO: add
# , argparse # lua argparse
, readline
}:

stdenv.mkDerivation rec {
  name = "rosie";
  version = "1.2.1";
  src = fetchFromGitLab {
    owner = "rosie-pattern-language";
    repo = "rosie";
  #src = fetchgit {
  #  url = https://gitlab.com/rosie-pattern-language/rosie;
    rev = "v${version}";
    sha256 = "0hzicg5vinzq8abzq163c1xzlwkp3hw6fqrla3v0252g5vdplgaf";
  };

  submodules = [
    (fetchFromGitHub {
      owner = "mpeterv";
      repo = "argparse";
      name = "argparse";
      rev = "412e6aca";
      sha256 = "0b4v0n1g0qh7jdkpq1ai8yq1di3l4kdpdb38hmkqhlgp8ip8j5p5";
    })
    (fetchFromGitLab {
      owner = "rosie-pattern-language";
      repo = "lua";
      name = "lua";
      rev = "afa03c03";
      sha256 = "1plj8m1gyv643isa2xdrc9gy1ny6bn87klcnvqcc6skrw5ggr0ls";
    })
    (fetchFromGitLab {
      owner = "rosie-pattern-language";
      repo = "lua-cjson";
      name = "lua-cjson";
      rev = "114e2abd";
      sha256 = "0j25nbyi8nlv2x5fa8xdwlw7s6qh8dx0x70i36smigxnn0n12m0h";
    })
    (fetchFromGitLab {
      owner = "rosie-pattern-language";
      repo = "lua-modules";
      name = "lua-modules";
      rev = "183449bc";
      sha256 = "0pf73dnxxcqjjipjsi787fgisydjxfp0n1g4vzk8iaj9lgvm13fz";
    })
    (fetchFromGitLab {
      owner = "rosie-pattern-language";
      repo = "lua-readline";
      name = "lua-readline";
      rev = "4aedcbdb";
      sha256 = "1f2ysarigki27vw4b160b5v7c6pkq0b3k47vjz9gyhz8jcqv329q";
    })
  ];

  postUnpack =
    (lib.concatMapStrings
      (submodule: ''
        rmdir ${src.name}/submodules/${submodule.name}
        cp --no-preserve=all -r ${submodule} ${src.name}/submodules/${submodule.name}

      '')
      submodules) +
    ''
      touch ${src.name}/submodules/~~present~~
    '';

  preConfigure = ''
    patchShebangs src/build_info.sh
    ln -s src submodules/lua/include
    substituteInPlace Makefile \
      --replace 'DESTDIR=/usr/local' "DESTDIR=$out"
  '';

  postInstall = ''
    rm $out/lib/rosie/build.log
  '';

  buildInputs = [ libbsd readline ];

  meta = with lib; {
    website = https://rosie-lang.org;
    description = "Tools for searching using parsing expression grammars";
    longDescription = "";
    license = licenses.mit;
    maintainers = with maintainers; [ kovirobi ];
  };
}
