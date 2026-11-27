extern "C" {

#include <cstdarg>
#include <cstddef>
#include <limits.h>

static bool is_space(char c)
{
    return c == ' ' || c == '\t' || c == '\n' || c == '\r' || c == '\v' || c == '\f';
}

static int digit_value(char c)
{
    if (c >= '0' && c <= '9')
        return c - '0';
    if (c >= 'a' && c <= 'z')
        return c - 'a' + 10;
    if (c >= 'A' && c <= 'Z')
        return c - 'A' + 10;
    return 36;
}

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

int sprintf(char *str, const char *format, ...)
{
    va_list args;
    va_start(args, format);
    int ret = __mingw_vsprintf(str, format, args);
    va_end(args);
    return ret;
}

int vsprintf(char *str, const char *format, va_list args)
{
    return __mingw_vsprintf(str, format, args);
}

int snprintf(char *str, size_t size, const char *format, ...)
{
    va_list args;
    va_start(args, format);
    int ret = __mingw_vsnprintf(str, size, format, args);
    va_end(args);
    return ret;
}

int vsnprintf(char *str, size_t size, const char *format, va_list args)
{
    return __mingw_vsnprintf(str, size, format, args);
}

char *strrchr(const char *str, int c)
{
    const char *ret = nullptr;

    do {
        if (*str == (char)c)
            ret = str;
    } while (*str++);

    return const_cast<char *>(ret);
}

char *strncpy(char *dest, const char *src, size_t count)
{
    char *ret = dest;

    while (count && *src) {
        *dest++ = *src++;
        count--;
    }
    while (count) {
        *dest++ = '\0';
        count--;
    }

    return ret;
}

unsigned long strtoul(const char *str, char **endptr, int base)
{
    const char *start = str;
    const char *digits;
    unsigned long value = 0;
    bool negative = false;
    bool overflow = false;

    while (is_space(*str))
        str++;

    if (*str == '+' || *str == '-') {
        negative = *str == '-';
        str++;
    }

    if (base == 0) {
        if (str[0] == '0' && (str[1] == 'x' || str[1] == 'X')) {
            base = 16;
            str += 2;
        } else if (str[0] == '0') {
            base = 8;
        } else {
            base = 10;
        }
    } else if (base == 16 && str[0] == '0' && (str[1] == 'x' || str[1] == 'X')) {
        str += 2;
    }

    if (base < 2 || base > 36) {
        if (endptr)
            *endptr = const_cast<char *>(start);
        return 0;
    }

    digits = str;
    while (true) {
        int digit = digit_value(*str);

        if (digit >= base)
            break;

        if (value > (ULONG_MAX - (unsigned long)digit) / (unsigned long)base)
            overflow = true;
        else
            value = value * (unsigned long)base + (unsigned long)digit;
        str++;
    }

    if (str == digits) {
        if (endptr)
            *endptr = const_cast<char *>(start);
        return 0;
    }

    if (endptr)
        *endptr = const_cast<char *>(str);

    if (overflow)
        return ULONG_MAX;

    return negative ? (unsigned long)(0UL - value) : value;
}

}
