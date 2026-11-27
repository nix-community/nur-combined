extern "C" {

#include <cstdarg>
#include <cstddef>
#include <cstdlib>
#include <setjmp.h>

int __mingw_vsprintf(char*, const char*, va_list);
int __mingw_vsnprintf(char*, size_t, const char*, va_list);

int __mingw_sprintf(char *str, const char *format, ...)
{
    va_list args;
    va_start(args, format);
    int ret = __mingw_vsprintf(str, format, args);
    va_end(args);
    return ret;
}

int __mingw_snprintf(char *str, size_t size, const char *format, ...)
{
    va_list args;
    va_start(args, format);
    int ret = __mingw_vsnprintf(str, size, format, args);
    va_end(args);
    return ret;
}

void longjmp(jmp_buf, int)
{
    std::abort();
}

}
