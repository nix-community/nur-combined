{ pkgs, stdenv, lib, fetchFromGitHub, makeWrapper, nodejs, jdk }: 

let
  version = "9.5.0";

  src = fetchFromGitHub {
    owner = "nvuillam";
    repo = "npm-groovy-lint";
    rev = "v${version}";
    sha256 = "sha256-dCgaKLSMF80riDomYfb+Y8CiWTFZ0Z1W5j0mBcTocn0=";
  };

  composition = import ./node-composition.nix {
    inherit pkgs nodejs;
    inherit (stdenv.hostPlatform) system;
  };

  compositionOverride = composition.nodeDependencies.override (old: {
    src = src;
    dontNpmInstall = true;
  });

in stdenv.mkDerivation rec {
  pname = "npm-groovy-lint";
  inherit version src;

  nativeBuildInputs = [
    makeWrapper
    nodejs
  ];
  
  buildPhase = ''
    runHook preBuild
    
    ln -s ${compositionOverride}/lib/node_modules .
    export PATH="${compositionOverride}/bin:$PATH"
    npm run build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,opt}
    cp -a . $out/opt/npm-groovy-lint

    makeWrapper ${nodejs}/bin/node $out/bin/npm-groovy-lint \
      --add-flags $out/opt/npm-groovy-lint/lib/index.js \
      --prefix PATH : ${lib.makeBinPath [ jdk ]}

    runHook postInstall
  '';

  meta = with lib; {
    description = "Lint, format and auto-fix your Groovy/Jenkinsfile/Gradle files using command line";
    homepage = "https://nvuillam.github.io/npm-groovy-lint/";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ wolfangaukang ];
  };
} 
