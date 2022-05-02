{ lib, stdenv, fetchFromGitHub, installShellFiles, python3 }:

python3.pkgs.buildPythonApplication rec {
  pname = "datalad";
  version = "0.16.2";

  doCheck = false;

  src = fetchFromGitHub {
    owner = "datalad";
    repo = pname;
    rev = version;
    hash = "sha256-0GGFud+Pjtz2Inst3u8lEVIdUsmvFVFxkWw76ZSmvdI=";
  };

  nativeBuildInputs = [ installShellFiles ];

  postInstall = ''
    installShellCompletion --cmd datalad \
         --bash <($out/bin/datalad shell-completion) \
         --zsh  <($out/bin/datalad shell-completion)
  '';

  propagatedBuildInputs = with python3.pkgs;
    [
      # core
      platformdirs
      chardet
      iso8601
      humanize
      fasteners
      packaging
      patool
      tqdm
      annexremote

      # downloaders
      boto
      keyrings-alt
      keyring
      msgpack
      requests

      # publish
      python-gitlab

      # misc
      argcomplete
      pyperclip
      python-dateutil

      # metadata
      simplejson
      whoosh

      # metadata-extra
      pyyaml
      mutagen
      exifread
      python-xmp-toolkit
      pillow

      # duecredit
      duecredit
    ] ++ lib.optional stdenv.hostPlatform.isWindows [ colorama ]
    ++ lib.optional (python3.pythonAtLeast "3.8") [ distro ]
    ++ lib.optional (python3.pythonOlder "3.10") [ importlib-metadata ];

  meta = with lib; {
    description =
      "Keep code, data, containers under control with git and git-annex";
    homepage = "https://www.datalad.org";
    license = licenses.mit;
  };
}
