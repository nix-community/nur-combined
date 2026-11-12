{
  dashing,
  lua5_5_compat,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation {
  pname = "docsets-lua-std";
  inherit (lua5_5_compat) version;

  src = ./.;

  nativeBuildInputs = [ dashing ];

  postPatch = ''
    cp -R ${lua5_5_compat.doc}/share/doc/* .
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
