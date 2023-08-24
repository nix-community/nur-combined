{ lib
, libgweather
, ...
}@attrs:
(libgweather.override
  (removeAttrs attrs [ "libgweather" ])
).overrideAttrs (upstream: {
  patches = lib.unique (
    (upstream.patches or []) ++ [
      ./nws-fix-null-string-comparison.patch
    ]
  );
})
