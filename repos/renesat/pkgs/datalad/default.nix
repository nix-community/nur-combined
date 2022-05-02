{ lib, stdenv, python39Packages, installShellFiles }:

with python39Packages;

buildPythonPackage rec {
  pname = "datalad";
  version = "0.16.2";

  doCheck = false;

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-H6stkrvRtoPuhkA6xjeVp1kgjUPX/yyC6SjGPyFP+HY=";
  };

  nativeBuildInputs = [ installShellFiles ];

  postInstall = ''
    installShellCompletion --cmd datalad \
         --bash <($out/bin/datalad shell-completion) \
         --zsh  <($out/bin/datalad shell-completion)
  '';

  propagatedBuildInputs = [
    # core
    platformdirs
    chardet
    distro # python_version >= "3.8"
    importlib-metadata # python_version < "3.10"
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
  ] ++ lib.lists.optional stdenv.hostPlatform.isWindows colorama;
}
