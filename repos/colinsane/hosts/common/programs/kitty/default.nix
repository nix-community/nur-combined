{ ... }:

{
  sane.programs.kitty.fs.".config/kitty/kitty.conf".symlink.text = ''
    # docs: https://sw.kovidgoyal.net/kitty/conf/
    # disable terminal bell (when e.g. you backspace too many times)
    enable_audio_bell no

    map ctrl+n new_os_window_with_cwd
    include ${./PaperColor_dark.conf}
  '';

  #  include ${pkgs.kitty-themes}/themes/PaperColor_dark.conf

  # THEME CHOICES:
  #   docs: https://github.com/kovidgoyal/kitty-themes
  # theme = "1984 Light";  # dislike: awful, harsh blues/teals
  # theme = "Adventure Time";  # dislike: harsh (dark)
  # theme = "Atom One Light";  # GOOD: light theme. all color combos readable. not a huge fan of the blue.
  # theme = "Belafonte Day";  # dislike: too low contrast for text colors
  # theme = "Belafonte Night";  # better: dark theme that's easy on the eyes. all combos readable. low contrast.
  # theme = "Catppuccin";  # dislike: a bit pale/low-contrast (dark)
  # theme = "Desert";  # mediocre: colors are harsh
  # theme = "Earthsong";  # BEST: dark theme. readable, good contrast. unique, but decent colors.
  # theme = "Espresso Libre";  # better: dark theme. readable, but meh colors
  # theme = "Forest Night";  # decent: very pastel. it's workable, but unconventional and muted/flat.
  # theme = "Gruvbox Material Light Hard";  # mediocre light theme.
  # theme = "kanagawabones";  # better: dark theme. colors are too background-y
  # theme = "Kaolin Dark";  # dislike: too dark
  # theme = "Kaolin Breeze";  # mediocre: not-too-harsh light theme, but some parts are poor contrast
  # theme = "Later This Evening";  # mediocre: not-too-harsh dark theme, but cursor is poor contrast
  # theme = "Material"; # decent: light theme, few colors.
  # theme = "Mayukai";  # decent: not-too-harsh dark theme. the teal is a bit straining
  # theme = "Nord";  # mediocre: pale background, low contrast
  # theme = "One Half Light";  # better: not-too-harsh light theme. contrast could be better
  # theme = "PaperColor Dark";  # BEST: dark theme, very readable still the colors are background-y
  # theme = "Parasio Dark";  # dislike: too low contrast
  # theme = "Pencil Light";  # better: not-too-harsh light theme. decent contrast.
  # theme = "Pnevma";  # dislike: too low contrast
  # theme = "Piatto Light";  # better: readable light theme. pleasing colors. powerline prompt is hard to read.
  # theme = "Rosé Pine Dawn";  # GOOD: light theme. all color combinations are readable. it is very mild -- may need to manually tweak contrast. tasteful colors
  # theme = "Rosé Pine Moon";  # GOOD: dark theme. tasteful colors. but background is a bit intense
  # theme = "Sea Shells";  # mediocre. not all color combos are readable
  # theme = "Solarized Light";  # mediocre: not-too-harsh light theme; GREAT background; but some colors are low contrast
  # theme = "Solarized Dark Higher Contrast";  # better: dark theme, decent colors
  # theme = "Sourcerer";  # mediocre: ugly colors
  # theme = "Space Gray";  # mediocre: too muted
  # theme = "Space Gray Eighties";  # better: all readable, decent colors
  # theme = "Spacemacs";  # mediocre: too muted
  # theme = "Spring";  # mediocre: readable light theme, but the teal is ugly.
  # theme = "Srcery";  # better: highly readable. colors are ehhh
  # theme = "Substrata";  # decent: nice colors, but a bit flat.
  # theme = "Sundried";  # mediocre: the solar text makes me squint
  # theme = "Symfonic";  # mediocre: the dark purple has low contrast to the black bg.
  # theme = "Tango Light";  # dislike: teal is too grating
  # theme = "Tokyo Night Day";  # medicore: too muted
  # theme = "Tokyo Night";  # better: tasteful. a bit flat
  # theme = "Tomorrow";  # GOOD: all color combinations are readable. contrast is slightly better than Rose. on the blander side
  # theme = "Treehouse";  # dislike: the orange is harsh on my eyes.
  # theme = "Urple";  # dislike: weird palette
  # theme = "Warm Neon";  # decent: not-too-harsh dark theme. the green is a bit unattractive
  # theme = "Wild Cherry";  # GOOD: dark theme: nice colors. a bit flat
  # theme = "Xcodedark";  # dislike: bad palette
  # theme = "citylights";  # decent: dark theme. some parts have just a bit low contrast
  # theme = "neobones_light"; # better light theme. the background is maybe too muted
  # theme = "vimbones";
  # theme = "zenbones_dark";  # mediocre: readable, but meh colors
  # theme = "zenbones_light";  # decent: light theme. all colors are readable. contrast is passable but not excellent. highlight color is BAD
  # theme = "zenwritten_dark";  # mediocre: looks same as zenbones_dark
}
