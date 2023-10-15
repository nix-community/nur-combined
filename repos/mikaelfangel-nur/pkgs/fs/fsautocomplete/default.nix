{ buildDotnetGlobalTool, lib }:

buildDotnetGlobalTool {
  pname = "fsautocomplete";
  version = "0.66.1";

  nugetSha256 = "sha256-U4CRbrP3KuzbwCOSNnYcnuECPDLL22uZjiwFK4R9nbs=";

  meta = with lib; {
    homepage = "https://github.com/fsharp/FsAutoComplete";
    license = licenses.asl20;
    platforms = platforms.linux;
  };
}
