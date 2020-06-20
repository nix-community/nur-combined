R: rPackages:
R.override {
  packages = with rPackages; [
    foreign
    ggplot2
    BoardGames
    shiny
    plumber
    rmarkdown
  ];
}
