{
  nsxiv,
  pkgs,
  fetchFromGitea,
}:

let
  # Rebase of the upstream square-thumbs patch
  # (https://codeberg.org/nsxiv/nsxiv-extra/raw/branch/master/patches/square-thumbs/square-thumbs-v31.diff)
  # onto nsxiv v34. The upstream URL only ships a v31 diff; once
  # nsxiv-extra adds a v34 diff, replace the writeText with fetchpatch.
  squareThumbsPatch = pkgs.writeText "square-thumbs-v34.diff" ''
    diff --git a/commands.c b/commands.c
    index 3257b1e..03a6b7b 100644
    --- a/commands.c
    +++ b/commands.c
    @@ -477,3 +477,11 @@ bool ct_select(arg_t _)

     	return dirty;
     }
    +
    +bool ct_toggle_squared(arg_t _)
    +{
    +	tns_toggle_squared();
    +	ct_reload_all(0);
    +
    +	return true;
    +}
    diff --git a/commands.h b/commands.h
    index 4e694f0..4de6b4d 100644
    --- a/commands.h
    +++ b/commands.h
    @@ -46,6 +46,7 @@ bool ct_reload_all(arg_t);
     bool ct_scroll(arg_t);
     bool ct_drag_mark_image(arg_t);
     bool ct_select(arg_t);
    +bool ct_toggle_squared(arg_t);

     #ifdef INCLUDE_MAPPINGS_CONFIG
     /* global */
    @@ -94,6 +95,7 @@ bool ct_select(arg_t);
     #define t_scroll { ct_scroll, MODE_THUMB }
     #define t_drag_mark_image { ct_drag_mark_image, MODE_THUMB }
     #define t_select { ct_select, MODE_THUMB }
    +#define t_toggle_squared { ct_toggle_squared, MODE_THUMB }

     #endif /* _MAPPINGS_CONFIG */
     #endif /* COMMANDS_H */
    diff --git a/config.def.h b/config.def.h
    index ead1509..23f13ad 100644
    --- a/config.def.h
    +++ b/config.def.h
    @@ -87,6 +87,10 @@ static const int thumb_sizes[] = { 32, 64, 96, 128, 160 };
     /* thumbnail size at startup, index into thumb_sizes[]: */
     static const int THUMB_SIZE = 3;

    +/* whether to show thumbnails in squares or respect their aspect ratio,
    + * toggleable with t_toggle_squared 's' keybinding in thumbnail mode */
    +static bool SQUARE_THUMBS = false;
    +
     #endif
     #ifdef INCLUDE_MAPPINGS_CONFIG

    @@ -144,6 +148,7 @@ static const keymap_t keys[] = {
     	{ 0,            XK_l,             t_move_sel,           DIR_RIGHT },
     	{ 0,            XK_Right,         t_move_sel,           DIR_RIGHT },
     	{ 0,            XK_R,             t_reload_all,         None },
    +	{ 0,            XK_s,             t_toggle_squared,     None },

     	{ 0,            XK_n,             i_navigate,           +1 },
     	{ 0,            XK_n,             i_scroll_to_edge,     DIR_LEFT | DIR_UP },
    diff --git a/nsxiv.h b/nsxiv.h
    index e0de301..e7a5760 100644
    --- a/nsxiv.h
    +++ b/nsxiv.h
    @@ -339,6 +339,7 @@ bool tns_move_selection(tns_t*, direction_t, int);
     bool tns_scroll(tns_t*, direction_t, bool);
     bool tns_zoom(tns_t*, int);
     int tns_translate(tns_t*, int, int);
    +bool tns_toggle_squared(void);


     /* util.c */
    diff --git a/thumbs.c b/thumbs.c
    index c72c01e..bc39247 100644
    --- a/thumbs.c
    +++ b/thumbs.c
    @@ -258,23 +258,36 @@ CLEANUP void tns_free(tns_t *tns)
     static Imlib_Image tns_scale_down(Imlib_Image im, int dim)
     {
     	int w, h;
    -	float z, zw, zh;

     	imlib_context_set_image(im);
     	w = imlib_image_get_width();
     	h = imlib_image_get_height();
    -	zw = (float)dim / (float)w;
    -	zh = (float)dim / (float)h;
    -	z = MIN(zw, zh);
    -	z = MIN(z, 1.0);
    -
    -	if (z < 1.0) {
    -		imlib_context_set_anti_alias(1);
    -		im = imlib_create_cropped_scaled_image(0, 0, w, h,
    -		                                       MAX(z * w, 1), MAX(z * h, 1));
    -		if (im == NULL)
    -			error(EXIT_FAILURE, ENOMEM, NULL);
    -		imlib_free_image_and_decache();
    +	if (SQUARE_THUMBS == false) { /* normal thumbs */
    +		float z, zw, zh;
    +		zw = (float)dim / (float)w;
    +		zh = (float)dim / (float)h;
    +		z = MIN(zw, zh);
    +		z = MIN(z, 1.0);
    +
    +		if (z < 1.0) {
    +			imlib_context_set_anti_alias(1);
    +			im = imlib_create_cropped_scaled_image(0, 0, w, h,
    +			                                       MAX(z * w, 1), MAX(z * h, 1));
    +			if (im == NULL)
    +				error(EXIT_FAILURE, ENOMEM, NULL);
    +			imlib_free_image_and_decache();
    +		}
    +	} else { /* generate square thumbs */
    +		int x = (w < h) ? 0 : (w - h) / 2;
    +		int y = (w > h) ? 0 : (h - w) / 2;
    +		int s = (w < h) ? w : h;
    +		if (dim < w || dim < h) {
    +			imlib_context_set_anti_alias(1);
    +			im = imlib_create_cropped_scaled_image(x, y, s, s, dim, dim);
    +			if (im == NULL)
    +				error(EXIT_FAILURE, ENOMEM, NULL);
    +			imlib_free_image_and_decache();
    +		}
     	}
     	return im;
     }
    @@ -637,3 +650,9 @@ int tns_translate(tns_t *tns, int x, int y)

     	return n;
     }
    +
    +bool tns_toggle_squared(void)
    +{
    +	SQUARE_THUMBS = !SQUARE_THUMBS;
    +	return true;
    +}
  '';
in

nsxiv.overrideAttrs (
  {
    patches ? [ ],
    postPatch ? "",
    ...
  }:
  {
    version = "34";
    src = fetchFromGitea {
      domain = "codeberg.org";
      owner = "nsxiv";
      repo = "nsxiv";
      rev = "v34";
      hash = "sha256-Yv5Px72iZWLtix0K7Tbzhkar7ZBSb121cBzMhkAZhak=";
    };
    patches = patches ++ [
      squareThumbsPatch
    ];
    postPatch = postPatch + ''
      # increase thumbnail sizes
      substituteInPlace config.def.h \
        --replace-fail '96, 128, 160' '96, 128, 160, 320, 640'  \
        --replace-fail 'THUMB_SIZE = 3' 'THUMB_SIZE = 5'  \
        --replace-fail 'SQUARE_THUMBS = false' 'SQUARE_THUMBS = true'
    '';
  }
)
