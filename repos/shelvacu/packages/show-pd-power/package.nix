{
  writers,
}:
writers.writePython3Bin "show-pd-power" {
  flakeIgnore = [
    "E501" #line too long? fuck you, 80 chars is way, way too short
  ];
} (builtins.readFile ./main.py)
