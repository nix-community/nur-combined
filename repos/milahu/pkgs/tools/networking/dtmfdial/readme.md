# dtmfdial

## todo

```
gcc -O -c dial.c
dial.c: In function 'main':
dial.c:268:17: warning: ignoring return value of 'write' declared with attribute 'warn_unused_result' [8;;https://gcc.gnu.org/onlinedocs/gcc/Warning-Options.html#index-Wunused-result-Wunused-result8;;]
  268 |                 write(fd, buf, bufidx);
      |                 ^~~~~~~~~~~~~~~~~~~~~~
dial.c: In function 'silent':
dial.c:355:25: warning: ignoring return value of 'write' declared with attribute 'warn_unused_result' [8;;https://gcc.gnu.org/onlinedocs/gcc/Warning-Options.html#index-Wunused-result-Wunused-result8;;]
  355 |                         write(fd, buf, bufsize);
      |                         ^~~~~~~~~~~~~~~~~~~~~~~
dial.c: In function 'dial':
dial.c:433:25: warning: ignoring return value of 'write' declared with attribute 'warn_unused_result' [8;;https://gcc.gnu.org/onlinedocs/gcc/Warning-Options.html#index-Wunused-result-Wunused-result8;;]
  433 |                         write(fd, buf, bufsize);
      |                         ^~~~~~~~~~~~~~~~~~~~~~~
```
