{
  lib,
  stdenvNoCC,
  proxychains,
}:
stdenvNoCC.mkDerivation {
  name = "proxychains-symlinks";
  srcs = [ ];
  sourceRoot = ".";

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  buildInputs = [ proxychains ];

  installPhase = ''
    install -d "$out"/{bin,share/zsh/site-functions}
    ln -s "${proxychains}/bin/proxychains4" "$out/bin/proxychains"
    echo -e '#compdef proxychains=proxychains4\n_proxychains4' > "$out/share/zsh/site-functions/_proxychains"
  '';

  meta = with lib; {
    homepage = "https://github.com/Freed-Wu/nur-packages";
    description = "symlinks for proxychains";
    license = licenses.gpl3;
    maintainers = with maintainers; [ Freed-Wu ];
    platforms = platforms.unix;
  };
}
