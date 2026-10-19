{
  lib,
  buildGoModule,
  fetchFromGitHub,
  makeWrapper,
  ffmpeg,
}:

buildGoModule (finalAttrs: {
  pname = "molten";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "pixelate-it";
    repo = "molten";
    tag = "v${finalAttrs.version}";
    hash = "sha256-VjTyMjfW5WCNSQOjxEuwrHnS3fAXHOLVcteTtxdo3RM=";
  };

  vendorHash = "sha256-ytZ8w0Wn2ChtcTs8GKHmtHHdCgrNH3WIA7r4E87vFnU=";

  subPackages = [ "cmd/molten" ];

  env.CGO_ENABLED = 0;

  ldflags = [
    "-s"
    "-w"
  ];

  nativeBuildInputs = [ makeWrapper ];

  # The renderer shells out to ffmpeg to encode video.
  postInstall = ''
    wrapProgram $out/bin/molten \
      --prefix PATH : ${lib.makeBinPath [ ffmpeg ]}
  '';

  meta = {
    description = "Protobuf-based stream format for recording and replaying collaborative pixel canvases";
    homepage = "https://github.com/pixelate-it/molten";
    changelog = "https://github.com/pixelate-it/molten/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mpl20;
    mainProgram = "molten";
    platforms = lib.platforms.unix;
  };
})
