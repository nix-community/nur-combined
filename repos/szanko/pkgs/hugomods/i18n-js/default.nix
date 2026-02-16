{ lib
, buildGoModule
, fetchFromGitHub
}:

buildGoModule (finalAttrs: {
  pname = "hugomods-i18n-js";
  version = "0.2.1";

  src = fetchFromGitHub {
    owner = "hugomods";
    repo = "i18n-js";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ugE43IjWqDGHGmHAc0Im/1HW/wGNbR6cqNzjum44EUU=";
  };

  vendorHash = null;

  ldflags = [ "-s" ];


  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/hugomods/i18n-js
    cp -r . $out/share/hugomods/i18n-js

    runHook postInstall
  '';



  meta = {
    description = "Globe_with_meridians: A i18n JS Module for Hugo";
    homepage = "https://hugomods.com/docs/i18n-js/";
    changelog = "https://github.com/hugomods/i18n-js/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers =
      let m = lib.maintainers or {};
      in lib.optionals (m ? szanko) [ m.szanko ];
  };
})
