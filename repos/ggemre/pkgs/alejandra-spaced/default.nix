{
  alejandra,
  lib,
}:
alejandra.overrideAttrs (old: {
  patches =
    (old.patches or [])
    ++ [
      ./spaced-elements.patch
    ];
  doCheck = false;
  meta = {
    description = "The Alejandra formatter  with spaces around elements.";
    homepage = "https://github.com/kamadorueda/alejandra";
    license = lib.licenses.unlicense;
    maintainers = [ lib.maintainers.kamadorueda ];
    platforms = lib.systems.doubles.all;
    mainProgram = "alejandra";
  };
})
