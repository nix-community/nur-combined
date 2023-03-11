{ sources, trivialBuild, lib }:

trivialBuild {
  inherit (sources.pyim-greatdict) pname version src;

  postInstall = ''
    cp *.gz $out/share/emacs/site-lisp
  '';

  meta = with lib; {
    description = "A chinese-pyim dict, which include three million words";
    homepage = "https://github.com/tumashu/pyim-greatdict";
    license = licenses.unfree;
    maintainers = with maintainers; [ yinfeng ];
  };
}
