{
  lib,
  python3,
  makeWrapper,
  nix,
  nix-prefetch,
}:

python3.pkgs.buildPythonApplication {
  pname = "brew2nur";
  version = "0.1.0";
  format = "other";

  src = ../../scripts/brew2nur.py;

  dontUnpack = true;
  dontBuild = true;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp $src $out/bin/brew2nur
    chmod +x $out/bin/brew2nur
    runHook postInstall
  '';

  postFixup = ''
    wrapProgram $out/bin/brew2nur \
      --prefix PATH : ${lib.makeBinPath [ nix nix-prefetch ]}
  '';

  meta = with lib; {
    description = "Convert Homebrew formulae and casks into NUR Nix packages";
    license = licenses.mit;
    maintainers = [ ];
    platforms = platforms.unix;
  };
}
