{
  toPythonModule,
  khoca,
  python,
}:

toPythonModule (khoca.override { python3 = python; })
