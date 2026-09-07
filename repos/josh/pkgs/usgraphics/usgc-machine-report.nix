{
  lib,
  stdenvNoCC,
  fetchFromGitHub,

  bash,
  coreutils,
  gawk,
  gnugrep,
  gnused,
  hostname,
  iproute2,
  makeWrapper,
  procps,
  util-linux,

  nix-update-script,
  runCommand,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "usgc-machine-report";
  version = "0-unstable-2026-05-06";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "usgraphics";
    repo = "usgc-machine-report";
    rev = "1c16ec002da2a55834678ccfc9a94ccba24d0d0c";
    hash = "sha256-Q7jxDN91w5jnYia0IopM1FtJ8LKkI4uHQd8fq1Kj8Bc=";
  };

  postPatch = ''
    substituteInPlace machine_report.sh \
      --replace-fail 'lastlog -u' 'lastlog2 -u'
  '';

  nativeBuildInputs = [ makeWrapper ];

  buildInputs = [ bash ];

  makeWrapperArgs = [
    "--prefix"
    "PATH"
    ":"
    (lib.strings.makeBinPath [
      # procps before coreutils, which also ships an uptime but without -p
      procps
      coreutils
      gawk
      gnugrep
      gnused
      hostname
      iproute2
      util-linux
    ])
  ];

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    install -Dm755 machine_report.sh $out/bin/usgc-machine-report
    patchShebangs --host $out/bin
    wrapProgram $out/bin/usgc-machine-report "''${makeWrapperArgs[@]}"

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  passthru.tests = {
    report =
      runCommand "test-usgc-machine-report-report"
        {
          __structuredAttrs = true;
          nativeBuildInputs = [ finalAttrs.finalPackage ];
        }
        ''
          env -u PATH ${lib.getExe finalAttrs.finalPackage} | tee report.txt
          grep -F "UNITED STATES GRAPHICS COMPANY" report.txt
          grep -F "TR-100 MACHINE REPORT" report.txt
          touch $out
        '';
  };

  meta = {
    description = "TR-100 machine report banner for server logins";
    homepage = "https://github.com/usgraphics/usgc-machine-report";
    license = lib.licenses.bsd3;
    mainProgram = "usgc-machine-report";
    platforms = lib.platforms.linux;
  };
})
