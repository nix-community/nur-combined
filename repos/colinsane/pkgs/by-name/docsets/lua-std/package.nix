{
  dashing,
  lua,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation {
  pname = "docsets-lua-std";
  inherit (lua) version;

  src = ./.;

  nativeBuildInputs = [ dashing ];

  postPatch = ''
    cp -R ${lua.doc}/share/doc/* .
  '';

  buildPhase = ''
    runHook preBuild

    dashing build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/docsets
    cp -R *.docset $out/share/docsets

    runHook postInstall
  '';
}
