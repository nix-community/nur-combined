{ pkgs, ... }:

{
  xdg.configFile."mr".source = ./mr/lib.mr;
  home.file."src/.mrconfig".source = ./mr/src.mr;
  home.file."src/tektoncd/.mrconfig".source = ./mr/src.tektoncd.mr;
  home.file."src/go.sbr.pm/.mrconfig".source = ./mr/src.go.sbr.pm.mr;
  home.file."src/k8s.io/.mrconfig".source = ./mr/src.k8s.io.mr;
  home.file."src/knative.dev/.mrconfig".source = ./mr/src.knative.dev.mr;
  # home.file."src/osp/forks/.mrconfig".source = ./mr/src.osp.forks.mr;
  home.file."src/osp/p12n/.mrconfig".source = ./mr/src.osp.p12n.mr;
  home.file."src/osp/.mrconfig".source = ./mr/src.osp.mr;
  # Old setup, migrate this slowly
  home.file."src/github.com/.mrconfig".source = ./mr/src.github.mr;
}
