{ lib
, buildGoModule
, fetchFromGitHub
}:

buildGoModule (finalAttrs: {
  pname = "hugomods-encoder";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "hugomods";
    repo = "encoder";
    tag = "v${finalAttrs.version}";
    hash = "sha256-sRUr5IZqRZ6FiKTJURWGKYbtX/hp/d33TL5G0LF4Szc=";
  };

  vendorHash = null;

  ldflags = [ "-s" ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/hugomods/encoder
    cp -r . $out/share/hugomods/encoder

    runHook postInstall
  '';

  meta = {
    description = "Encode text to protect email address and telephone number from spam bots";
    homepage = "https://hugomods.com/docs/encoder/";
    changelog = "https://github.com/hugomods/encoder/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers =
      let m = lib.maintainers or {};
      in lib.optionals (m ? szanko) [ m.szanko ];
  };
})
