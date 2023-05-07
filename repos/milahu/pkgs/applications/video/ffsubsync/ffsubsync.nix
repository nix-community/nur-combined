{ lib
, python3
, fetchFromGitHub
}:

python3.pkgs.buildPythonApplication rec {
  pname = "ffsubsync";
  stableVersion = "0.4.22";
  version = "${stableVersion}-unstable-2023-05-04";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "smacke";
    repo = "ffsubsync";
    #rev = version;
    #hash = "sha256-Tlnw098ndO32GsRq3SQ0GpNdZl9WEPBsDOHZYl1BI8E=";
    rev = "7fd1885b00ff68eceef2f557c334bebdd30f7ae5";
    hash = "sha256-NWkxLyqvgct0v8xWxoaI3WTZLBqXC835zFBzWFqqlls=";
  };

  buildInputs = with python3.pkgs; [
    setuptools
  ];

  # this did not work. instead, patch "__version__ = ..."
  /*
    # ffsubsync/constants.py
    #SUBSYNC_RESOURCES_ENV_MAGIC=ffsubsync_resources_xj48gjdkl340
    #mkdir -p $SUBSYNC_RESOURCES_ENV_MAGIC
    #echo $stableVersion >$SUBSYNC_RESOURCES_ENV_MAGIC/__version__
    #mkdir -p ffsubsync/$SUBSYNC_RESOURCES_ENV_MAGIC
    #echo $stableVersion >ffsubsync/$SUBSYNC_RESOURCES_ENV_MAGIC/__version__
    # debug
    #substituteInPlace ffsubsync/version.py \
    #  --replace 'def get_version():' $'def get_version():\n    print("__version__", repr(__version__))'
  */

  postPatch = ''
    sed -i 's/==/>=/g' requirements.txt

    # fix: FileNotFoundError: [Errno 2] No such file or directory: 'ffsubsync/__version__'
    echo $stableVersion >ffsubsync/__version__

    # fix: KeyError: 'ffsubsync_resources_xj48gjdkl340'
    substituteInPlace ffsubsync/version.py \
      --replace \
       '__version__ = get_versions()["version"]' \
       "__version__ = '$stableVersion'"
  '';

  propagatedBuildInputs = with python3.pkgs; [
    auditok
    cchardet
    chardet
    charset-normalizer
    faust-cchardet
    ffmpeg-python
    future
    numpy
    pysubs2
    rich
    six
    srt
    tqdm
    typing-extensions
    # webrtcvad is broken on runtime:
    # ModuleNotFoundError: No module named 'pkg_resources'
    # fix: add setuptools
    # https://github.com/wiseman/py-webrtcvad/pull/87
    # TODO fix: nixpkgs/pkgs/development/python-modules/webrtcvad/default.nix
    (webrtcvad.overrideAttrs (oldAttrs: {
      propagatedBuildInputs = (oldAttrs.propagatedBuildInputs or []) ++ (with python3.pkgs; [
        setuptools
      ]);
    }))
    #webrtcvad-wheels # binary release
  ];

  pythonImportsCheck = [ "ffsubsync" ];

  meta = with lib; {
    description = "Automagically synchronize subtitles with video";
    homepage = "https://github.com/smacke/ffsubsync";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}
