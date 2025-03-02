{ lib, stdenvNoCC, gnuradio-boost181, gnuradio-modules }:

let 
  gnuradio = gnuradio-boost181;
  gnuradioPackages = {
    inherit (gnuradio-modules) gr-foo gr-ieee-802-15-4;
  };
  gr = (gnuradio.override {
    extraPackages = builtins.attrValues gnuradioPackages;
    extraPythonPackages = with gnuradio.python.pkgs; [ soapysdr ];
  }) // {
    pkgs = gnuradio.pkgs.overrideScope (final: prev: gnuradioPackages);
  };
in
stdenvNoCC.mkDerivation {
  name = "ieee-802-15-4-sniffer";
  version = "1.0";
  src = ./.;

  nativeBuildInputs = [ gr.unwrapped gr.python.pkgs.wrapPython ];
  buildInputs = [ gr.pythonEnv ];

  buildPhase = ''
    runHook preBuild
    export HOME=$TMPDIR
    GRCC="${lib.getExe' gr "grcc"}"
    echo GRCC=$GRCC

    # Generate the flow graph both locally and in the (temporary) local gr directory, so it can find it when building the next flow graph
    $GRCC ${gr.pkgs.gr-ieee-802-15-4}/share/gr-ieee802_15_4/examples/ieee802_15_4_OQPSK_PHY.grc
    $GRCC -u ${gr.pkgs.gr-ieee-802-15-4}/share/gr-ieee802_15_4/examples/ieee802_15_4_OQPSK_PHY.grc
    $GRCC soapy-oqpsk-sniffer.grc

    runHook postBuild
    '';


  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    mkdir -p $out/${gr.pythonEnv.sitePackages}
    cp ./*.py $out/${gr.pythonEnv.sitePackages}
    # cp ./oqpsk_sniffer.py $out/bin/ieee-802-15-4-sniffer
    cp ${./sniffer.py} $out/bin/ieee-802-15-4-sniffer
    runHook postInstall
  '';

  postFixup = ''
    patchShebangs $out/bin
    for cmd in $out/bin/*; do
      echo $cmd
      wrapProgram $cmd \
      --prefix PATH : "${gr.pythonEnv}" \
      --prefix PYTHONPATH : "${gr.pythonEnv}/${gr.pythonEnv.sitePackages}:$out/${gr.pythonEnv.sitePackages}"
    done
  '';

  passthru = {
    gnuradio = gr;
  };

  meta = {
    mainProgram = "ieee-802-15-4-sniffer";
    platforms = gnuradio.meta.platforms;
  };
}

