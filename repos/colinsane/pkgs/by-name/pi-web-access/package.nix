{
  fetchFromGitHub,
  lib,
  mkPiExtension,
  nix-update-script,
}:
mkPiExtension (finalAttrs: {
  pname = "pi-web-access";
  version = "0.48.0";

  src = fetchFromGitHub {
    owner = "nicobailon";
    repo = "pi-web-access";
    tag = "v${finalAttrs.version}";
    hash = "sha256-kvxwqQzvUEvBU8URxTCe4hGbWiUa41TbsdtdiM6+GqE=";
  };

  npmDepsFetcherVersion = 2;
  npmDepsHash = "sha256-7+To46sc8xq08/qTstJ+EsboX/YFMUhigxR8Su737UM=";

  # allegedly, pi loads index.ts and jit's it _at runtime_. or, i can patch it to load the compiled (dist) version.
  # postPatch = ''
  #   substituteInPlace package.json \
  #     --replace-fail '"./index.ts"' '"./dist"'
  # '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Pi extension for web search, URL fetching, GitHub repo cloning, PDF extraction, and YouTube video understanding";
    homepage = "https://github.com/nicobailon/pi-web-access";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ colinsane ];
    platforms = lib.platforms.linux;
  };
})
