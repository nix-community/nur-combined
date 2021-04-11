{
  go = { buildWeechatScript }: buildWeechatScript {
    pname = "go.py";
    version = "2.6";
    sha256 = "0zgy1dgkzlqjc0jzbdwa21yfcnvlwx154rlzll4c75c1y5825mld";
  };
  auto_away = { buildWeechatScript }: buildWeechatScript {
    pname = "auto_away.py";
    version = "0.4";
    sha256 = "02my55fz9cid3zhnfdn0xjjf3lw5cmi3gw3z3sm54yif0h77jwbn";
  };
  autoconf = { buildWeechatScript }: buildWeechatScript {
    pname = "autoconf.py";
    version = "0.3";
    sha256 = "1i81imlx4bcy3xl01lld1shj1wxqx2ixl72fwknb0s90gn7j4jrc";
  };
  autosort = { buildWeechatScript }: buildWeechatScript {
    pname = "autosort.py";
    version = "3.8";
    sha256 = "1y0xrblzlygggn05l95zb195w9pd85rig4y1mfqca2f922izcccp";
  };
  colorize_nicks = { buildWeechatScript }: buildWeechatScript {
    pname = "colorize_nicks.py";
    version = "27";
    sha256 = "0hiay88vvy171jiq6ahflm0ipb7sslfxwhmmm8psv6qk19rv2sxs";
  };
  unread_buffer = { buildWeechatScript }: buildWeechatScript {
    pname = "unread_buffer.py";
    version = "2";
    sha256 = "0xrds576lvvbbimg9zl17s62zg0nyymv4qnjsbjx770hcwbbyp2s";
  };
  urlgrab = { buildWeechatScript }: buildWeechatScript {
    pname = "urlgrab.py";
    version = "3.0";
    sha256 = "1z940g7r5w7qsay5jl7mr4ra9nyw3cgp5398i9xkmd0cxqw9aiw7";
    patches = [
      ./urlgrab-homedir.patch
    ];
  };
  vimode = { buildWeechatScript }: buildWeechatScript {
    pname = "vimode.py";
    version = "0.8.1";
    sha256 = "1nz0y4w1r0whcrsqrwk6vc6f1lz62qkph5i445zjdgqy98x1v9bf";
  };
  vimode-git = { fetchFromGitHub, stdenvNoCC, fetchurl }: stdenvNoCC.mkDerivation rec {
    pname = "vimode.py";
    version = "2019-11-10";
    rev = "4e926c39bd21de15c146e2a0bea1b85684ef08f2";
    src = fetchFromGitHub {
      owner = "GermainZ";
      repo = "weechat-vimode";
      rev = rev;
      sha256 = "1h3r437vv5sg6f801praxm2prf4x8izkayi690qvfz2vsdzdxksv";
    };

    patches = let
      fixrev = "bd3593834abc8f40f53c1bc8b68ab1e5d58241d9";
      sha256 = "1930q1ngnhb4fl4isnfv2lz5vry3i6n91zdhjfrsywfrqna3y499";
    in [ (fetchurl {
      name = "weechat-vimode-arc.patch";
      url = "https://github.com/GermainZ/weechat-vimode/compare/GermainZ:${rev}...arcnmx:${fixrev}.diff";
      inherit sha256;
    }) ];

    installPhase = ''
      install -Dt $out/share vimode.py
    '';

    passthru.scripts = [ pname ];
  };

  weechat-matrix = { stdenvNoCC, weechat-matrix-contrib, lib }: stdenvNoCC.mkDerivation {
    pname = "weechat-matrix";
    inherit (weechat-matrix-contrib) version src;

    weechatMatrixContrib = weechat-matrix-contrib;
    buildPhase = "true";
    installPhase = ''
      install -D main.py $out/share/matrix.py

      install -d $out/bin
      ln -s $weechatMatrixContrib/bin/matrix_{upload,decrypt} $out/bin/
    '';

    passthru.scripts = [ "matrix.py" ];
  };
}
