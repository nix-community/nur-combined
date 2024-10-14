{
  stdenvNoCC, lib, fetchurl,
  p7zip,
}:
let
  pname = "sarasa-term-sc-nerd-font";
  version = "1.1.0";
  src = fetchurl {
    url = "https://github.com/laishulu/Sarasa-Term-SC-Nerd/releases/download/v${version}/sarasa-term-sc-nerd.ttc.7z";
    hash = "sha256-WwfZPFhbDYOi4uskgZ/AqgqLgyV4Vf3QC7KVHg+Z0wE=";
  };
in
stdenvNoCC.mkDerivation {
  inherit pname version src;
  nativeBuildInputs = [ p7zip ];
  dontUnpack = true;

  installPhase = ''
    7z x ${src}
    mkdir -p $out/share/fonts/truetype
    install --mode=644 ./*.ttc $out/share/fonts/truetype
  '';

  meta = with lib; {
    description = "简体中文终端更纱黑体+Nerd图标字体库。中英文宽度完美2:1，图标长宽经过调整，不会出现对齐问题，尤其适合作为终端字体。";
    homepage = "https://github.com/laishulu/Sarasa-Term-SC-Nerd";
    license = licenses.ofl;
  };
}
