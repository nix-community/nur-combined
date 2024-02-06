{ ... }:
{
  sane.programs.superTuxKart = {
    sandbox.method = "bwrap";
    sandbox.wrapperType = "wrappedDerivation";
    sandbox.whitelistDri = true;
    persist.byStore.plaintext = [
      ".cache/supertuxkart"
      ".config/supertuxkart"
      ".local/share/supertuxkart"
    ];
  };
}
