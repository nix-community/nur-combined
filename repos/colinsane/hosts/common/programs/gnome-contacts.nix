{ pkgs, ... }: {
  sane.programs.gnome-contacts = {
    packageUnwrapped = pkgs.gnome-contacts.overrideAttrs (upstream: {
      # patches = (upstream.patches or []) ++ [
      #   # optional danctnix patch to allow clicking on the telephone to open the calls app,
      #   # however it's frequently in need of rebasing
      #   (pkgs.fetchpatch {
      #     url = "https://github.com/dreemurrs-embedded/Pine64-Arch/raw/5c6cb98127ddb0f503c6ba0afc973194248c7c9d/PKGBUILDS/phosh/gnome-contacts-mobile/0001-ContactSheet-Add-make-call-and-send-sms-button.patch";
      #     name = "contact-sheet: Add call and send sms buttons";
      #     hash = "sha256-jUGEk+h0ciqKcXh29rOcGopqKWxBXTDKbZJOuE4R04U=";
      #   })
      # ];

      # gnome-contacts doesn't know which apps i have installed, and so thinks i don't have maps installed, and so doesn't show the "open in maps" icon.
      # force it to show; it gets handled correctly in the end, by the portal.
      # i can also add ~/.local/share/applications as an alternate fix;
      # apparently glib URI launcher uses portal so long as the .desktop file it *would* choose *isn't* dbus-activatable.
      #
      # TODO: report this bug upstream? i'm such an edgecase here though that i don't know if it's reasonable to expect this to work or not.
      postPatch = (upstream.postPatch or "") + ''
        substituteInPlace src/contacts-contact-sheet.vala --replace-fail \
          'var map_uris_supported = (appinfo != null);' \
          'var map_uris_supported = true;'
      '';
    });

    gsettings."org/gnome/Contacts" = {
      # else it will ask you to choose the default address book on each launch
      did-initial-setup = true;
    };

    sandbox.whitelistDbus.user.call."org.gnome.evolution.dataserver.*" = "*";  #< TODO: reduce; only needs address book and maybe sources (probably not calendar, 'cept maybe for birthdays?)
    sandbox.whitelistDbus.user.own = [ "org.gnome.Contacts" ];
    sandbox.whitelistDri = true;  #< speculative, but i'd like it to be responsive on mobile
    sandbox.whitelistPortal = [
      "OpenURI"
    ];
    sandbox.whitelistWayland = true;

    sandbox.mesaCacheDir = ".cache/gnome-calendar/mesa";  # TODO: is this the correct app-id?

    suggestedPrograms = [
      "evolution-data-server"  #< REQUIRED for saving/loading of any contacts
    ];
  };
}
