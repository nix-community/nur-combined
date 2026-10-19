# The phone's XML services: the Messages button's visual voicemail, from
# usecallmanager.nz's sample services app, and the Directories button's
# contacts list, which is ours.
{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  python3,
  makeWrapper,
}:
let
  python = python3.withPackages (ps: [
    ps.flask
    ps.gunicorn
    ps.lxml
    ps.pyyaml
    ps.requests
  ]);
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "cisco-phone-services";
  version = "3.0";

  src = fetchFromGitHub {
    owner = "usecallmanagernz";
    repo = "services";
    rev = "v${finalAttrs.version}";
    hash = "sha256-yqmsz1p6SKhjpQp+/QECCtHNAP/6TcgcLe8ct/Db9zo=";
  };

  nativeBuildInputs = [ makeWrapper ];

  postPatch = ''
    substituteInPlace messages.py \
      --replace-fail "tag('CicoIPPhoneText'" "tag('CiscoIPPhoneText'" \
      --replace-fail "'%H:%M, %d/%m/%Y'" "'%H:%M, %m/%d/%Y'"
  '';

  installPhase = ''
    runHook preInstall
    share=$out/share/cisco-phone-services
    install -Dm444 -t $share config.py messages.py
    install -Dm444 ${./contacts.py} $share/contacts.py
    install -Dm444 ${./app.py} $share/app.py
    makeWrapper ${python}/bin/gunicorn $out/bin/cisco-phone-services \
      --add-flags "--pythonpath $share app:application"
    runHook postInstall
  '';

  meta.mainProgram = "cisco-phone-services";
})
