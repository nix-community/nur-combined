{
  lib,
  stdenvNoCC,
  gopass,
}:
stdenvNoCC.mkDerivation {
  name = "gopass-symlinks";
  srcs = [ ];
  sourceRoot = ".";

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  buildInputs = [ gopass ];

  installPhase = ''
    install -d "$out"/{bin,share/zsh/site-functions}
    ln -s "${gopass}/bin/gopass" "$out/bin/pass"
    echo -e '#compdef pass=gopass\n_gopass' > "$out/share/zsh/site-functions/_pass"
  '';

  meta = with lib; {
    homepage = "https://github.com/Freed-Wu/nur-packages";
    description = "symlinks for gopass";
    license = licenses.gpl3;
    maintainers = with maintainers; [ Freed-Wu ];
    platforms = platforms.unix;
  };
}
