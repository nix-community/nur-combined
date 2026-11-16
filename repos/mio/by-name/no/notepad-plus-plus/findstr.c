/*
 * Minimal findstr.exe for Wine: upstream Wine findstr lacks [character class]
 * support, which breaks Notepad++'s NppLibsVersionH-generator.bat.
 * Implements /L, /C:, /R enough for that script ([0-9]* classes and *).
 */
#define _CRT_SECURE_NO_WARNINGS
#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static int literal = 0, regex = 0;
static char needle[4096];

static int match_class(const char **ppat, int ch) {
  const char *p = *ppat;
  int neg = 0, ok = 0;
  if (*p == '^') {
    neg = 1;
    ++p;
  }
  while (*p && *p != ']') {
    int a = (unsigned char)*p++;
    if (*p == '-' && p[1] && p[1] != ']') {
      int b = (unsigned char)p[1];
      p += 2;
      if (ch >= a && ch <= b)
        ok = 1;
    } else if (ch == a) {
      ok = 1;
    }
  }
  if (*p == ']')
    ++p;
  *ppat = p;
  return neg ? !ok : ok;
}

static int atom_len(const char *pat, const char **end) {
  if (*pat == '[') {
    const char *p = pat + 1;
    while (*p && *p != ']')
      ++p;
    if (*p == ']')
      ++p;
    *end = p;
    return 1;
  }
  if (*pat) {
    *end = pat + 1;
    return 1;
  }
  *end = pat;
  return 0;
}

static int match_atom(const char *pat, const char *end, int ch) {
  (void)end;
  if (pat[0] == '[') {
    const char *p = pat + 1;
    return match_class(&p, ch);
  }
  if (pat[0] == '.')
    return 1;
  return (unsigned char)pat[0] == (unsigned char)ch;
}

static int match_here(const char *pat, const char *text);

static int match_here(const char *pat, const char *text) {
  while (*pat) {
    const char *atom_end;
    if (!atom_len(pat, &atom_end))
      return 0;
    if (*atom_end == '*') {
      const char *rest = atom_end + 1;
      for (;;) {
        if (match_here(rest, text))
          return 1;
        if (!*text || !match_atom(pat, atom_end, (unsigned char)*text))
          return 0;
        ++text;
      }
    } else {
      if (!*text || !match_atom(pat, atom_end, (unsigned char)*text))
        return 0;
      ++text;
      pat = atom_end;
    }
  }
  return 1;
}

static int match_regex(const char *pat, const char *text) {
  for (; *text; ++text)
    if (match_here(pat, text))
      return 1;
  return match_here(pat, text);
}

static int line_matches(const char *line) {
  char buf[8192];
  size_t n = strlen(line);
  while (n && (line[n - 1] == '\n' || line[n - 1] == '\r'))
    n--;
  if (n >= sizeof buf)
    n = sizeof buf - 1;
  memcpy(buf, line, n);
  buf[n] = 0;
  if (regex)
    return match_regex(needle, buf);
  (void)literal;
  return strstr(buf, needle) != NULL;
}

static void search_file(FILE *f) {
  char buf[8192];
  while (fgets(buf, sizeof buf, f))
    if (line_matches(buf))
      fputs(buf, stdout);
}

int main(int argc, char **argv) {
  int i;
  needle[0] = 0;
  for (i = 1; i < argc; i++) {
    if (!strcmp(argv[i], "/L") || !strcmp(argv[i], "/l"))
      literal = 1;
    else if (!strcmp(argv[i], "/R") || !strcmp(argv[i], "/r"))
      regex = 1;
    else if (!strncmp(argv[i], "/C:", 3) || !strncmp(argv[i], "/c:", 3))
      strncpy(needle, argv[i] + 3, sizeof needle - 1);
    else if ((!strcmp(argv[i], "/C") || !strcmp(argv[i], "/c")) && i + 1 < argc)
      strncpy(needle, argv[++i], sizeof needle - 1);
    else if (argv[i][0] == '/')
      continue;
    else if (!needle[0])
      strncpy(needle, argv[i], sizeof needle - 1);
    else {
      FILE *f = fopen(argv[i], "rb");
      if (!f)
        return 1;
      search_file(f);
      fclose(f);
      return 0;
    }
  }
  search_file(stdin);
  return 0;
}
