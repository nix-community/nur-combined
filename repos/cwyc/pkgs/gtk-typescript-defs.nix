{atk, glib, gtk3, gdk-pixbuf, pango, cairo, callPackage}:
(callPackage ../lib/ts-for-gjs {} {
	name = "gtk-typescript-defs";
	sources = [
		atk.dev
		gtk3.dev
		gdk-pixbuf.dev
	];
	ignore = [];
	prettify = false;
}).override {
	meta = {
		description = "A set of typescript definitions for coding with gtk";
	};
}