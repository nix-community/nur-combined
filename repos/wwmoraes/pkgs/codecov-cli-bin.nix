{
  lib,
  stdenvNoCC,
  fetchurl,
  darwin ? { },
}:

stdenvNoCC.mkDerivation rec {
  pname = "codecov-cli-bin";
  version = "9.0.4";

  src =
    let
      inherit (stdenvNoCC.hostPlatform) system;
      selectSystem = attrs: attrs.${system} or (throw "Unsupported system: ${system}");
      os = selectSystem {
        aarch64-darwin = "macos";
        aarch64-linux = "linux-arm64";
        i686-linux = "linux";
        x86_64-darwin = "macos";
        x86_64-linux = "linux";
      };
      hash = selectSystem {
        aarch64-darwin = "sha256-3KisRLIaeFSWUHthYaGoiKesV0yic8cjfcDE6UAIYoE=";
        aarch64-linux = "sha256-dbcy3Nl98pTYbzukfdTB/BwiXhCGrh2nq7wtDMCicxM=";
        i686-linux = "sha256-QoA7fMIuKOEqAshENc1vb73kGUb7FQOPB5FmmQZQigM=";
        x86_64-darwin = "sha256-3KisRLIaeFSWUHthYaGoiKesV0yic8cjfcDE6UAIYoE=";
        x86_64-linux = "sha256-QoA7fMIuKOEqAshENc1vb73kGUb7FQOPB5FmmQZQigM=";
      };
    in
    fetchurl {
      inherit hash;
      url = "https://cli.codecov.io/v${version}/${os}/codecov";
    };

  dontUnpack = true;

  installPhase = ''
    		runHook preInstall
    		mkdir -p $out/bin
    		install -D $src $out/bin/codecov
    		${lib.optionalString stdenvNoCC.hostPlatform.isDarwin ''
        			cd $out/bin
        			mv codecov codecov_universal
        			${lib.getBin darwin.binutils-unwrapped}/bin/lipo codecov_universal -thin ${stdenvNoCC.hostPlatform.darwinArch} -output codecov
        			rm codecov_universal
        		''}
    		runHook postInstall
    	'';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck
    $out/bin/codecov --help > /dev/null
    $out/bin/codecov --version > /dev/null
    runHook postInstallCheck
  '';

  meta = with lib; {
    description = "Codecov's Command Line Interface. Used for uploading to Codecov in your CI, Test Labelling, Local Upload, and more";
    mainProgram = "codecov";
    license = licenses.asl20;
    homepage = "https://github.com/codecov/codecov-cli";
    maintainers = [ maintainers.wwmoraes ];
  };
}
