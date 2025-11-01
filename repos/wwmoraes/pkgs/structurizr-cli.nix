{
  fetchzip,
  jre,
  lib,
  stdenvNoCC,
  writeShellScriptBin,
}:

stdenvNoCC.mkDerivation rec {
  pname = "structurizr-cli";
  version = "2024.07.03";

  src = fetchzip {
    url = "https://github.com/structurizr/cli/releases/download/v${version}/structurizr-cli.zip";
    hash = "sha256-DFwxYaVft4t+UKZHGSCV/8HAd/FpT1kkQhzAnFMH4sM=";
    stripRoot = false;
  };

  wrapped = writeShellScriptBin "structurizr-cli" ''
    		exec ${jre}/bin/java \
    			$VMARGS \
    			-classpath "$out/share/structurizr-cli/*" \
    			com.structurizr.cli.StructurizrCliApplication \
    			"$@"
    	'';

  buildCommand = ''
    		mkdir -p $out/share/structurizr-cli
    		install -Dm644 $src/lib/* $out/share/structurizr-cli

    		mkdir -p $out/bin
    		cp ${wrapped}/bin/structurizr-cli $out/bin/structurizr-cli

    		substituteInPlace $out/bin/structurizr-cli \
    			--replace-fail '$out' "$out"
    	'';

  doInstallCheck = true;
  postCheckInstall = ''
    		$out/bin/structurizr-cli help
    	'';

  meta = {
    description = "Command-line utility for Structurizr";
    homepage = "https://structurizr.com";
    license = lib.licenses.asl20;
    mainProgram = "structurizr-cli";
    maintainers = with lib.maintainers; [ wwmoraes ];
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
  };
}
