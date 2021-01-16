{atk, glib, gtk, gdk-pixbuf, pango, cairo, lib}:
lib.ts-for-gjs {
	name = "my-bundle";
	sources = with pkgs; [
		atk.dev
		glib.dev
		gtk.dev
		gdk-pixbuf.dev
		pango.dev
		cairo.dev
	];
	ignore = [];
	prettify = false;
}