{
  fetchzip,
  graphviz,
  jre,
  lib,
  stdenvNoCC,
  writeShellScriptBin,
}:

stdenvNoCC.mkDerivation rec {
  pname = "structurizr-site-generatr";
  version = "1.3.0";

  src = fetchzip {
    url = "https://github.com/avisi-cloud/structurizr-site-generatr/releases/download/${version}/structurizr-site-generatr-${version}.tar.gz";
    hash = "sha256-53/PiVi9XLPlUMlTCoHqA8XF+rdbEUwAne+T1BVJKDQ=";
  };

  wrapped = writeShellScriptBin "structurizr-site-generatr" ''
    		export PATH=${lib.makeBinPath [ graphviz ]}:$PATH

    		exec ${jre}/bin/java \
    			$STRUCTURIZR_SITE_GENERATR_OPTS \
    			-classpath "$out/share/structurizr-site-generatr/*" \
    			nl.avisi.structurizr.site.generatr.AppKt \
    			"$@"
    	'';

  buildCommand = ''
    		mkdir -p $out/share/structurizr-site-generatr
    		install -Dm644 $src/lib/* $out/share/structurizr-site-generatr

    		mkdir -p $out/bin
    		cp ${wrapped}/bin/structurizr-site-generatr $out/bin/structurizr-site-generatr

    		substituteInPlace $out/bin/structurizr-site-generatr \
    			--replace-fail '$out' "$out"
    	'';

  doInstallCheck = true;
  postCheckInstall = ''
    		$out/bin/structurizr-site-generatr version
    	'';

  meta = {
    description = "Static site generator for architecture models created with Structrizr DSL";
    homepage = "https://github.com/avisi-cloud/structurizr-site-generatr";
    license = lib.licenses.asl20;
    mainProgram = "structurizr-site-generatr";
    maintainers = with lib.maintainers; [ wwmoraes ];
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
  };
}
