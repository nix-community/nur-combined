{
  lib,
  stdenvNoCC,
  makeWrapper,
  util-linux,
}:

stdenvNoCC.mkDerivation {
  pname = "dms-ccusage-plugin";
  version = "1.0.0";

  src = lib.fileset.toSource {
    root = ./.;
    fileset = lib.fileset.unions [
      ./plugin.json
      ./CcusageWidget.qml
      ./ccusage-usage.sh
    ];
  };

  nativeBuildInputs = [ makeWrapper ];

  postPatch = ''
    substituteInPlace CcusageWidget.qml \
      --replace-fail "@ccusage-usage@" "$out/bin/ccusage-usage"
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out $out/bin
    cp plugin.json CcusageWidget.qml $out/

    install -m755 ccusage-usage.sh $out/bin/ccusage-usage
    wrapProgram $out/bin/ccusage-usage \
      --prefix PATH : ${lib.makeBinPath [ util-linux ]}

    runHook postInstall
  '';

  meta = {
    description = "DMS plugin showing Claude Code billing block usage";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ aciceri ];
  };
}
