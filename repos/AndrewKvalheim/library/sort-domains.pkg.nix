{ writers }:

writers.writePython3Bin "sort-domains" { } ''
  import sys


  def reverse_domain(domain):
      return ".".join(reversed(domain.split(".")))


  sys.stdout.writelines(sorted(sys.stdin, key=reverse_domain))
''
