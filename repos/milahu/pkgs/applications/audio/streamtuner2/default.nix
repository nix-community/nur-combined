{
  lib,
  stdenv,
  fetchfossil,
  callPackage,
  python3,
  glib,
  atk,
  pango,
  harfbuzz,
  gtk3,
  gdk-pixbuf,
}:

let
  versionnum = callPackage ./versionnum.nix { };

  pluginconf = python3.pkgs.callPackage ./pluginconf.nix { };

  pythonInputs = with python3.pkgs; [
    # based on Makefile
    requests
    pyquery
    lxml
    pillow
    xdg
    pluginconf
    pygobject3 # from gi import pygtkcompat as pygtk
    # FIXME urllib3/connectionpool.py:1099: InsecureRequestWarning: Unverified HTTPS request is being made to host 't1.gstatic.com'.
    #   Adding certificate verification is strongly advised.
    #   See: https://urllib3.readthedocs.io/en/latest/advanced-usage.html#tls-warnings
    urllib3
    idna
    certifi
    cssselect
    chardet
    charset-normalizer
  ];

  gtkInputs = [
    glib
    atk
    pango
    harfbuzz
    gtk3
    gdk-pixbuf
  ];
in

stdenv.mkDerivation rec {
  pname = "streamtuner2";
  version = "2.2.2";

  src = fetchfossil {
    url = "http://fossil.include-once.org/streamtuner2";
    /*
    rev = version;
    hash = "sha256-PckGwUqL2r5KJEet8sS4U504G63flX84EkQEkQdMifY=";
    */
    rev = "cfb8433564d490c66a63ad1dfc3aca7a07c17607";
    hash = "sha256-iye1LGYLb33O/EidSx9lTYt9vdYDNVZCnc9rI4hr2uE=";
  };

  nativeBuildInputs = [
    versionnum
  ];

  # fix: make: *** No rule to make target 'gtk3.xml', needed by 'gtk3.xml.gz'.  Stop.
  # fix: mkdir: cannot create directory '/usr': Permission denied
  # fix: pip: command not found
  preBuild = ''
    gzip -d gtk3.xml.gz
    sed -i "s|/usr/share/|$out/share/|g; s|/usr/bin/streamtuner2|$out/bin/streamtuner2|g" Makefile st2.py bin streamtuner2.desktop action.py gtk3.xml
    mkdir -p $out/bin
    mkdir -p $out/share/applications
    mkdir -p $out/share/pixmaps
    mkdir -p $out/share/man/man1
    sed -i "s|pip install |# &|g" Makefile

    substituteInPlace bin \
      --replace-fail \
        'sys.path.insert' \
        "$(
          # fix: ImportError: cannot import name GObject, introspection typelib not found
          # https://github.com/NixOS/nixpkgs/issues/45662
          # https://github.com/NixOS/nixpkgs/issues/341038
          echo 'os.environ["GI_TYPELIB_PATH"] = "${lib.makeSearchPathOutput "lib" "lib/girepository-1.0" gtkInputs}"'

          # add python dependencies
          echo 'sys.path += [${
            builtins.concatStringsSep ", " (
              builtins.map (s: ''"${s}/${python3.sitePackages}"'') pythonInputs
            )
          }]'

          echo 'sys.path.insert'
        )"

    # TODO upstream patch
    # use raw strings
    # fix: SyntaxWarning: invalid escape sequence '\s'
    sed -i -E 's/(re\.(findall|sub|match|search|compile))\((["'"'"'])/\1(r\3/g' bin st2.py action.py config.py uikit.py channels/*.py

    substituteInPlace action.py channels/*.py \
      --replace-quiet '"[\$\%]("' 'r"[\$\%]("' \
      --replace-quiet ', "\g<1>",' ', r"\g<1>",' \
      --replace-quiet 'title = """' 'title = r"""' \
      --replace-quiet 'listeners = """' 'listeners = r"""' \
      --replace-quiet 'playing = """' 'playing = r"""' \
      --replace-quiet 'tags = """' 'tags = r"""' \
      --replace-quiet 'url = """' 'url = r"""' \
      --replace-quiet 'fmt = """' 'fmt = r"""' \

  '';

  passthru = {
    inherit versionnum;
  };

  meta = {
    description = "Internet radio browser GUI for music/video streams from various directory services";
    homepage = "http://fossil.include-once.org/streamtuner2";
    license = lib.licenses.publicDomain; # st.py
    maintainers = with lib.maintainers; [ ];
    mainProgram = "streamtuner2";
    platforms = lib.platforms.all;
  };
}
