/* The three runtime entry points upstream's dummy block in print.cpp does not
 * cover, but which FreeType and HarfBuzz reference on a mingw freestanding
 * link.  They abort like every other dummy there: upstream's setjmp stub
 * returns 0, so the longjmp path is unreachable by construction. */

extern "C" {

#include <cstdarg>
#include <cstddef>
#include <setjmp.h>

void abort();

void longjmp(jmp_buf, int)
{
    abort();
}

int __mingw_sprintf(char*, const char*, ...)
{
    abort();
}

int __mingw_snprintf(char*, size_t, const char*, ...)
{
    abort();
}

}
