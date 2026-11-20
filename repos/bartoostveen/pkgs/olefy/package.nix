{
  lib,
  python3Packages,
  fetchFromGitHub,
  nix-update-script,
  makeWrapper,
}:

python3Packages.buildPythonApplication {
  pname = "olefy";
  version = "0-unstable-2026-11-05";

  format = "other";

  src = fetchFromGitHub {
    owner = "HeinleinSupport";
    repo = "olefy";
    rev = "9c01c571f11da1a41dda33b75e46d45d303270e4";
    hash = "sha256-dR36Um3HoKVLrYFgL4XhUT5GSWtuGlEV6xXxL04df5Q=";
  };

  nativeInstallInputs = [
    makeWrapper
  ];

  installPhase = ''
    mkdir -p $out/{bin,${python3Packages.python.sitePackages}}

    install -Dm755 olefy.py $out/${python3Packages.python.sitePackages}/olefy.py

    makeWrapper ${python3Packages.python.interpreter} $out/bin/olefy \
      --add-flags "$out/${python3Packages.python.sitePackages}/olefy.py" \
      --set OLEFY_PYTHON_PATH "${python3Packages.python.interpreter}" \
      --set OLEFY_OLEVBA_PATH "${lib.getExe' python3Packages.oletools "olevba"}" \
      --set PYTHONPATH "$out/${python3Packages.python.sitePackages}:${
        python3Packages.python.withPackages (
          ps: with ps; [
            colorclass
            python-magic
            oletools
          ]
        )
      }/${python3Packages.python.sitePackages}"
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch=main" ]; };

  meta = {
    description = "Small Python Daemon to use oletools over TCP sockets. Mainly to use oletools in Rspamd.";
    homepage = "https://github.com/HeinleinSupport/olefy";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ bartoostveen ];
    mainProgram = "olefy";
  };
}
