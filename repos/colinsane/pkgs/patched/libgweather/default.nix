{ lib
, libgweather
, fetchpatch
, ...
}@attrs:
(libgweather.override
  (removeAttrs attrs [ "fetchpatch" "libgweather" ])
).overrideAttrs (upstream: {
  patches = lib.unique (
    (upstream.patches or []) ++ [
      (fetchpatch {
        url = "https://gitlab.gnome.org/GNOME/libgweather/-/merge_requests/282.patch";
        name = "nws: fix null string comparison when reading visibility";
        hash = "sha256-2sfRVvVbUL8jCSuZXlZxs5VYFJlRmFjwL1L6oF0zGo8=";
      })
    ]
  );
})
