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

    # FIXME how can the hash change with the same rev
    /*
      is the github archive endpoint non-deterministic?
      did a hardware-defect cause some data-corruption?
      this silent error would be no surprise
      because the github archive endpoint is lossy
      because it does not provide the raw commit object
      so we cannot verify data by commit hash
      see also
      Nix sha256 is bug not feature. solution: a global /cas filesystem
      https://discourse.nixos.org/t/nix-sha256-is-bug-not-feature-solution-a-global-cas-filesystem/15791
    */
    /*
      error: hash mismatch in fixed-output derivation '/nix/store/p1ibf131ay7v673hjzlffarf50d6cjsk-source.drv':
               specified: sha256-NWkxLyqvgct0v8xWxoaI3WTZLBqXC835zFBzWFqqlls=
                  got:    sha256-3phxNKp3EpXzU8Fw9lCO8sWL949P41WtzYu9+Ty7ISc=
    */
    rev = "7fd1885b00ff68eceef2f557c334bebdd30f7ae5";
    #hash = "sha256-NWkxLyqvgct0v8xWxoaI3WTZLBqXC835zFBzWFqqlls=";
    hash = "sha256-3phxNKp3EpXzU8Fw9lCO8sWL949P41WtzYu9+Ty7ISc=";
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

    # fix: Found duplicated packages in closure for dependency 'faust-cchardet':
    #   faust-cchardet 2.1.18 (/nix/store/5dh8azfs1lw8g8l44ha8f4msmvsqjvl1-python3.10-faust-cchardet-2.1.18/lib/python3.10/site-packages)
    #   faust-cchardet 2.1.18 (/nix/store/y7ga51jnjkn7784mrhfnxv69d2nisdyp-faust-cchardet-2.1.18/lib/python3.10/site-packages)
    #faust-cchardet

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
