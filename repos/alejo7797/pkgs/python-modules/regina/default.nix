{
  toPythonModule,
  python,
  regina-normal,
}:

toPythonModule (
  regina-normal.override { python3 = python; withGUI = false; }
)
