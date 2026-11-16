# the `shfmt` bash script formatter, but adjusted to personal taste.
#
# `case` formatting; see: <https://github.com/mvdan/sh/issues/1168>
# shfmt-sane formats as such:
# ```
# case $arg in
#-  --help)
#+  (--help)
#     do_thing
#     ;;
# esac
# ```
{ shfmt }:
shfmt.overrideAttrs (prevAttrs: {
  pname = "shfmt-sane";
  patches = (prevAttrs.patches or [ ]) ++ [
    ./keep-opening-case-paren.patch
  ];
})
