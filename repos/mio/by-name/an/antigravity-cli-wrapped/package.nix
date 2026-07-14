{
  antigravity-cli,
  makeWrapper,
}:

antigravity-cli.overrideAttrs (oldAttrs: {
  pname = "antigravity-cli-patched";

  nativeBuildInputs = (oldAttrs.nativeBuildInputs or [ ]) ++ [ makeWrapper ];

  postInstall = (oldAttrs.postInstall or "") + ''
    wrapProgram $out/bin/agy --set NO_COLOR 1
    wrapProgram $out/bin/antigravity --set NO_COLOR 1
  '';
})
