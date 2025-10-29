import re

pattern = re.compile(
    r"^\| ([a-zA-Z0-9_]+) \| ([0-9a-fx]+) \|", flags=re.MULTILINE | re.IGNORECASE
)

map_lines = ""
with open("ALGORITHMS.md") as f:
    for line in f.readlines():
        match = pattern.search(line)
        if not match:
            continue
        name = match[1]
        nid = match[2]
        map_lines += "{" + nid + ', "' + name + '"},\n'

print(
    """
static const struct {
  int nid;
  char* name;
} oqs_nid_map[] = {
"""
    + map_lines
    + """
};
static const int oqs_nid_map_len = sizeof(oqs_nid_map) / sizeof(oqs_nid_map[0]);

const char* oqs_nid_lookup(int nid) {
  for (int i = 0; i < oqs_nid_map_len; i++) {
    if (oqs_nid_map[i].nid == nid) {
      return oqs_nid_map[i].name;
    }
  }
  return 0;
}
"""
)
