{ lib
, python3
, fetchFromGitHub
}:

python3.pkgs.buildPythonApplication rec {
  pname = "ffsubsync";
  version = "0.4.26";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "smacke";
    repo = "ffsubsync";
    rev = version;
    hash = "sha256-vON/nVZ0W2kYLsRyAGugCFM4EA3bVxXCXDn26zMlIoA=";
  };

  buildInputs = with python3.pkgs; [
    setuptools
  ];

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
    mainProgram = "ffsubsync";
  };
}
