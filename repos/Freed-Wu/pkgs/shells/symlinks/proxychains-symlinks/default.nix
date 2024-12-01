{
  lib,
  stdenvNoCC,
  proxychains,
  fetchurl,
}:
stdenvNoCC.mkDerivation {
  name = "proxychains-symlinks";
  src = (
    fetchurl {
      url = "https://raw.githubusercontent.com/haad/proxychains/refs/commit/02409fba797da68fa6a06c2c9290e8e43366fd8a/completions/zsh/_proxychains4";
      sha256 = "sha256-pvqN40tZiGzITgSJm6FpwlOuMx2oHn7OOU4uhyEF7Bo=";
    }
  );

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  buildInputs = [ proxychains ];

  installPhase = ''
    install -d "$out"/{bin,share/zsh/site-functions}
    install -Dm644 $src "$out/share/zsh/site-functions/_proxychains4"
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
