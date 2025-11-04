{ lib
, python3
, fetchFromGitHub
}:

python3.pkgs.buildPythonApplication rec {
  pname = "archive.org-downloader";
  version = "unstable-2025-04-04";

  src = fetchFromGitHub {
    owner = "MiniGlome";
    repo = "Archive.org-Downloader";
    rev = "d9cd9e51539b63dbf2fa7c8b20f4b17f37200dd8";
    hash = "sha256-9Snj2mfgPVvnXoqRTrb8DtnTiAkqGlvEaVHx5Hcm6iQ=";
  };


  propagatedBuildInputs = with python3.pkgs; [
    requests
    tqdm
    img2pdf
    pycryptodome
  ];
  doCheck = false;

  patchPhase = ''
    sed -i 's/\r$//' archive-org-downloader.py

    if ! head -n1 archive-org-downloader.py | grep -q '^#!'; then
    printf '#!/usr/bin/env python3\n' | cat - archive-org-downloader.py > archive-org-downloader.py.new
    mv archive-org-downloader.py.new archive-org-downloader.py
    fi
    '';


  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    install -m755 archive-org-downloader.py $out/bin/archive-org-downloader

    substituteInPlace $out/bin/archive-org-downloader \
    --replace "python3" "${python3}/bin/python3" || true

    runHook postInstall
    '';

  format = "other";

  meta = {
    description = "Python3 script to download archive.org books in PDF format";
    homepage = " https://github.com/MiniGlome/Archive.org-Downloader.git";
    license = lib.licenses.unfree; 
    maintainers =
      let m = lib.maintainers or {};
      in lib.optionals (m ? szanko) [ m.szanko ];
    mainProgram = "archive-org-downloader";
    platforms = lib.platforms.all;
  };
}
