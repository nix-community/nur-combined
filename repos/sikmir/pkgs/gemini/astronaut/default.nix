{
  lib,
  stdenv,
  buildGoModule,
  fetchFromSourcehut,
  scdoc,
  installShellFiles,
}:

buildGoModule (finalAttrs: {
  pname = "astronaut";
  version = "0.1.3";

  src = fetchFromSourcehut {
    owner = "~adnano";
    repo = "astronaut";
    rev = finalAttrs.version;
    hash = "sha256-YkaeJMabEHGcyYeEyiYXR2K8YKX7Qqo5mb1XzvKT2+U=";
  };

  nativeBuildInputs = [
    scdoc
    installShellFiles
  ];

  vendorHash = "sha256-4obhPl3Yvlrsf+C0vFpS/EOPEK7Kwm3GgbZ/ociihD8=";

  ldflags = [ "-X main.ShareDir=${placeholder "out"}/share/astronaut" ];

  postBuild = ''
    scdoc < docs/astronaut.1.scd > docs/astronaut.1
  '';

  postInstall = ''
    installManPage docs/astronaut.1
    install -Dm644 config/*.conf -t $out/share/astronaut
  '';

  meta = {
    description = "A Gemini browser for the terminal";
    homepage = "https://sr.ht/~adnano/astronaut";
    license = lib.licenses.gpl3Only;
    maintainers = [ lib.maintainers.sikmir ];
  };
})
