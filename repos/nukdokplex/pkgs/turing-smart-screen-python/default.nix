{ lib
, fetchFromGitHub
, fontPackages ? [ ]
, themePackages ? [ ]
, tsspConfiguration ? { }
, python312
, pyamdgpuinfo
, gputil-mathoudebine
, ...
}:
let
  versionInfo = builtins.fromJSON (builtins.readFile ./version.json);
  owner = "mathoudebine";
  tsspDir = "$out/share/turing-smart-screen-python";
in
python312.pkgs.buildPythonApplication rec {
  pname = "turing-smart-screen-python";
  version = versionInfo.rev;

  src = fetchFromGitHub {
    inherit owner;
    repo = pname;
    inherit (versionInfo) rev hash;
  };

  format = "other";
  patches = [ ./disable-log-file.patch ];

  propagatedBuildInputs = with python312.pkgs; [
    pyserial
    pyyaml
    psutil
    babel
    uptime
    requests
    ping3
    pillow
    numpy
    gputil-mathoudebine
    pyamdgpuinfo
  ];

  passthru = {
    python = python312;
    # PYTHONPATH of all deps used by the package
    pythonPath = python312.pkgs.makePythonPath propagatedBuildInputs;
  };

  installPhase = ''
    mkdir -p "${tsspDir}/res/themes" "${tsspDir}/res/fonts"
    cp -a library main.py "${tsspDir}"
    cp -a "res/themes/default.yaml" "${tsspDir}/res/themes"
    chmod +x "${tsspDir}/main.py"
    makeWrapper "${tsspDir}/main.py" "${tsspDir}/run" \
      --prefix PYTHONPATH : "$PYTHONPATH"
    echo ${lib.escapeShellArg (builtins.toJSON tsspConfiguration)} > "${tsspDir}/config.yaml"
  '' + builtins.concatStringsSep "\n" (
    (builtins.map
      (theme: "ln -sf \"${theme}\" \"${tsspDir}/res/themes/${theme.pname}\"")
      themePackages
    ) ++
    (builtins.map
      (font: "ln -sf \"${font}\" \"${tsspDir}/res/fonts/${font.pname}\"")
      fontPackages
    )
  );
}

