{}:

rec {
  pname = "protonmail-bridge-headless";

  tags = "pmapi_prod nogui";

  # FIXME: There's something fucky going on in the buildFlagsArray
  # substitution. I shouldn't need to do this.
  buildPhase =
    let
      t = "github.com/ProtonMail/proton-bridge/pkg/constants";
    in
    ''
      runHook preBuild

      go install \
        -tags="${tags}" \
        -ldflags="-X ${t}.Version=1.3.2 -X ${t}.Revision=unknown -X ${t}.BuildDate=unknown" \
        cmd/Desktop-Bridge/main.go
      mv $GOPATH/bin/main $GOPATH/bin/Desktop-Bridge
        
      runHook postBuild
    '';

  # Fix up name.
  postInstall = ''
    mv $out/bin/Desktop-Bridge $out/bin/protonmail-bridge
  '';
}
