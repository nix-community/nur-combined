{
  theme,
  type,
  side,
  color,
  screen,
  logo,
  background,
}:
builtins.elem theme [
  "forest"
  "mojave"
  "mountain"
  "wave"
]
&& builtins.elem type [
  "window"
  "float"
  "sharp"
  "blur"
]
&& builtins.elem side [
  "left"
  "right"
]
&& builtins.elem color [
  "dark"
  "light"
]
&& builtins.elem screen [
  "1080p"
  "2k"
  "4k"
]
&& builtins.elem logo [
  "default"
  "system"
]
