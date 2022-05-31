/*
nix-build -E 'with import <nixpkgs> { }; callPackage ./tg-archive.nix { }'
./result/bin/tg-archive
*/

{ lib
, python3Packages
, fetchFromGitHub
, fetchpatch
, gtk3
, wrapGAppsHook
, gdk-pixbuf
, gobject-introspection
, gettext
, gst_all_1
, gspell
, isocodes
, intltool
, rustPlatform
, file # libmagic
}:

let

  fetchPypi = python3Packages.fetchPypi;

  cryptg = python3Packages.buildPythonPackage rec {
    pname = "cryptg";
    #version = "0.3.1"; # ERROR: The Cargo.lock file doesn't exist
    version = "0.3.1.unstable-2022-05-10";
    src = fetchFromGitHub {
      owner = "cher-nov";
      repo = "cryptg";
      rev = "e5a86364e9fd77cadbea94d48e28fded0f2a6e1a";
      sha256 = "sha256-0v+GmwjWierq7a4c548hFLuq1dSDo8PvDlii5HK7MWk=";
    };
    cargoDeps = rustPlatform.fetchCargoTarball {
      inherit src;
      #inherit src sourceRoot;
      name = "${pname}-${version}";
      sha256 = "sha256-StTCVh0NBEE6J7fV+sCq2eOmhuRDgyS711qZDwduWm0=";
    };
    #sourceRoot = "source/bindings/python";
    nativeBuildInputs = /*[ python3Packages.setuptools-rust ] ++*/ (with rustPlatform; [
      cargoSetupHook
      rust.cargo
      rust.rustc
    ]);
    buildInputs = (with python3Packages; [
      #importlib-resources
      setuptools-rust
    ]);
    propagatedBuildInputs = (with python3Packages; [
      #jsonschema
      #h_matchers
    ]);
    checkInputs = with python3Packages; [
    ];
    meta = with lib; {
      homepage = "https://github.com/cher-nov/cryptg";
      description = "Cryptographic utilities for Telegram";
      license = licenses.cc0;
    };
  };

  python-magic = python3Packages.buildPythonPackage rec {
    pname = "python-magic";
    version = "0.4.26";
    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-gmLBMAH5BK1bck04teW18X7ARQriSd7zmKYuTjMQilA=";
    };
    buildInputs = (with python3Packages; [
      #importlib-resources
    ]);
    # https://github.com/ahupp/python-magic/blob/master/magic/loader.py#L34
    postPatch = ''
      sed -i "s|yield 'libmagic.so.1'|yield '${file}/lib/libmagic.so.1'|" magic/loader.py
    '';
    propagatedBuildInputs = (with python3Packages; [
      #jsonschema
      #h_matchers
      file # libmagic
    ]);
    checkInputs = with python3Packages; [
      file # libmagic
    ];
    meta = with lib; {
      homepage = "http://github.com/ahupp/python-magic";
      description = "File type identification using libmagic";
      license = licenses.mit;
    };
  };

in

python3Packages.buildPythonApplication rec {
  pname = "tg-archive";
  version = "unstable-2022-02-17";
  src = fetchFromGitHub {
    owner = "knadh";
    repo = "tg-archive";
    rev = "0eec29ad5977d4aad6def27f285104994ee71f5b";
    sha256 = "sha256-2ATO3ZkaY5w4JmoUUgf4Bn/UD7u0zu3W5GUqvCdGIB8=";
  };
  # relax dependencies
  postPatch = ''
    sed -i 's/==/>=/' requirements.txt
  '';
  patches = [
    (fetchpatch {
      url = "https://github.com/knadh/tg-archive/pull/61.diff";
      sha256 = "sha256-XQFW715HbrxFUUYfKhwk7/IQ7Cnbjtqk32Pq7q/tn3M=";
    })
    (fetchpatch {
      url = "https://github.com/knadh/tg-archive/pull/63.diff";
      sha256 = "sha256-49ZCrYH5r3ekcv51pJPoHHVfhu1GzEMhfXjvlPBiQn8=";
    })
    (fetchpatch {
      url = "https://github.com/knadh/tg-archive/pull/65.diff";
      sha256 = "sha256-Ul0ZMIZf2OY0oADVoqwfvQJpc1SoZ6DhsAafolFpXII=";
    })
    (fetchpatch {
      url = "https://github.com/knadh/tg-archive/pull/66.diff";
      sha256 = "sha256-bQS2nY++VqEabmCy1Bj70VEx4DHMLO/69Q6TvMH6HNw=";
    })
  ];
  propagatedBuildInputs = with python3Packages; [
    #python-telegram-bot # gi
    telethon
    jinja2
    pyyaml # PyYAML
    cryptg
    pillow # Pillow
    feedgen
    python-magic
    #pkg_resources
    setuptools # pkg_resources
  ];
  buildInputs = [
    /*
    gtk3 # Pango
    gobject-introspection # Pango

    # optional
    gspell
    isocodes
    python3Packages.chardet
    #python3Packages.distutils_extra

    # optional: internal video player
    gst_all_1.gstreamer
    #gst_all_1.gstreamer.dev # gst-inspect
    gst_all_1.gst-plugins-base # playbin
    (gst_all_1.gst-plugins-good.override { gtkSupport = true; }) # gtksink
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-ugly
    gst_all_1.gst-libav
    */
  ];
  nativeBuildInputs = [
    /*
    gettext # msgfmt
    wrapGAppsHook
    gobject-introspection
    #intltool
    */
  ];
  /*
  postInstall = ''
    cat >>$out/lib/python3.9/site-packages/aeidon/paths.py <<EOF
    DATA_DIR = '$out/share/gaupol'
    LOCALE_DIR = '$out/share/locale'
    EOF
  '';
  */
  #doCheck = false; # tests are failing: Unable to init server: Could not connect: Connection refused
  meta = with lib; {
    homepage = "https://github.com/knadh/tg-archive";
    description = "export Telegram group chats into static websites to preserve chat history like mailing list archives";
    #maintainers = [];
    license = licenses.mit;
    #platforms = platforms.linux;
  };
}
