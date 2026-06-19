{ ... }:
{
  sane.programs.kagi-epiphany = {
    sandbox.method = null;  #< TODO: sandbox
    mime.urlAssociations."^https?://(www\\.)?kagi.com$" = "kagi-epiphany.desktop";
    mime.urlAssociations."^https?://(www\\.)?kagi.com/.*$" = "kagi-epiphany.desktop";

    persist.byStore.private = [
      ".local/share/org.gnome.Epiphany.WebApp_424cfc679f24e45b65660e152e6ba961a21645ce"
    ];
  };
}
