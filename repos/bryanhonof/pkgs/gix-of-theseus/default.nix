{
  lib,
  rustPlatform,
  fetchCrate,
  makeBinaryWrapper,
  uv,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "gix-of-theseus";
  version = "2.0.0";

  src = fetchCrate {
    inherit (finalAttrs) pname version;
    hash = "sha256-p8Wo3Il8Cr1N3zcPq0Brx8Exl5G3i6VAJnJZ93QGPJs=";
  };

  cargoHash = "sha256-GLfHQeJGAbFQVTek1hBZ8U2omyiuty2nnnHdbdlG0/4=";

  nativeBuildInputs = [ makeBinaryWrapper ];

  # Plotting shells out to a PEP 723 runner; --suffix leaves the user's own first.
  postInstall = ''
    wrapProgram $out/bin/gix-of-theseus \
      --suffix PATH : ${lib.makeBinPath [ uv ]}
  '';

  meta = with lib; {
    description = "Track a repo's composition over time";
    homepage = "https://github.com/amedeedaboville/gix-of-theseus";
    changelog = "https://github.com/amedeedaboville/gix-of-theseus/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = licenses.asl20;
    maintainers = with maintainers; [ bryanhonof ];
    platforms = platforms.unix;
    mainProgram = "gix-of-theseus";
  };
})
