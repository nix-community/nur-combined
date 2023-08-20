{ lib
, fetchFromGitHub
, buildPythonApplication
, requests
, tqdm
, img2pdf
}:

buildPythonApplication rec {
  pname = "archive-org-downloader";
  version = "2023.01.16";
  propagatedBuildInputs = [
    requests
    tqdm
    img2pdf
  ];
  src = fetchFromGitHub {
    repo = "Archive.org-Downloader";
    owner = "MiniGlome";
    rev = "8575c86156eacb7fc1e3096ec164455232b23a0c";
    sha256 = "sha256-/QM11tFvNYXTnl3oRRkZRRoSdiYnd5TZj51CpO/8qqk=";
  };

  setup-py = ''
    from setuptools import setup, find_packages
    setup(
      name='archive-org-downloader',
    	version='${version}',
    	packages=find_packages(),
    	scripts=["archive-org-downloader.py"],
    )
  '';

  postPatch = ''
    echo ${lib.escapeShellArg setup-py} >setup.py
    sed -i 's/\r//' archive-org-downloader.py
    sed -i '1 i\#!/usr/bin/env python3\n' archive-org-downloader.py
    chmod +x archive-org-downloader.py
  '';

  meta = with lib; {
    description = "download books from archive.org";
    homepage = "https://github.com/MiniGlome/Archive.org-Downloader";
    #license = licenses.mit; # no license
    platforms = platforms.all;
  };
}
