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
    version = "3.6";
    sha256 = "0i56y0glp23krkahrrfzrd31y3pj59z7skr1przlkngwdbrpf06r";
  };
  colorize_nicks = { buildWeechatScript }: buildWeechatScript {
    pname = "colorize_nicks.py";
    version = "26";
    sha256 = "1ldk6q4yhwgf1b8iizr971vqd9af6cz7f3krd3xw99wd1kjqqbx5";
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
  };
  vimode = { buildWeechatScript }: buildWeechatScript {
    pname = "vimode.py";
    version = "0.7";
    sha256 = "1ypn5hkz9n7qjmk22h86lz8sikf7a4wql08cc0540a5lwd4m2qgz";
  };
  vimode-git = { fetchFromGitHub, stdenvNoCC, fetchurl }: stdenvNoCC.mkDerivation rec {
    pname = "vimode.py";
    version = "2019-06-26";
    rev = "6412084ae263a75790b8ea6fb36c75a7eb06c16b";
    src = fetchFromGitHub {
      owner = "GermainZ";
      repo = "weechat-vimode";
      rev = rev;
      sha256 = "0ad06yd5lmpdvv10lm16fhp3z32c7ayvzx53gn654lzgy68y5ssi";
    };

    patches = let
      fixrev = "a4d049fa8b863918b3204630cd6c0ac5291541c3";
      sha256 = "1pqbn7168qz33658ibs9gycc52xnpkr453qsadf3ca9mliwi0k50";
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

  weechat-matrix = { stdenvNoCC, weechat-matrix-contrib }: stdenvNoCC.mkDerivation {
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
