{ lib
, fetchFromGitHub
, makeWrapper
, python3
}:

python3.pkgs.buildPythonApplication {
  pname = "sherlock";
  version = "unstable-2023-08-29";
  format = "other";

  src = fetchFromGitHub {
    owner = "sherlock-project";
    repo = "sherlock";
    rev = "cf171c7b7292adebb2f14cc3e8fde447f424c499";
    sha256 = "sha256-m6lhD0p5JZV+Bcx7dbe+VzNzs6U0Nxd+GydGxoPeg4g=";
  };

  nativeBuildInputs = [ makeWrapper ];

  pythonPath = with python3.pkgs; [
    certifi
    colorama
    pandas
    pysocks
    requests
    requests-futures
    stem
    torrequest
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/opt/sherlock
    cp -R . $out/opt/sherlock

    runHook postInstall
  '';

  postFixup = ''
    makeWrapper ${python3.interpreter} $out/bin/sherlock \
      --add-flags $out/opt/sherlock/sherlock/sherlock.py \
      --prefix PYTHONPATH : "$PYTHONPATH"
  '';

  # All tests require access to the net
  doCheck = false;

  meta = {
    description = "Hunt down social media accounts by username across social networks";
    homepage = "https://github.com/sherlock-project/sherlock";
    maintainers = with lib.maintainers; [ wolfangaukang ];
    platforms = lib.platforms.unix;
    licenses = lib.licenses.mit;
    mainProgram = "sherlock";
  };
}
