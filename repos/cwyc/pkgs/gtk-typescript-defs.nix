{atk, glib, gtk3, gdk-pixbuf, pango, cairo, callPackage}:
(callPackage ../lib/ts-for-gjs {} {
	name = "gtk-typescript-defs";
	sources = [
		atk.dev
		glib.dev
		gtk3.dev
		gdk-pixbuf.dev
		pango.dev
		cairo.dev
	];
	ignore = [];
	prettify = false;
}).override {
	meta = {
		description = "A set of typescript definitions for coding with gtk";
	};
}