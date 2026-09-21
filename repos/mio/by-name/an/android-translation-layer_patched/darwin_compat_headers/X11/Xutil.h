#ifndef XUTIL_H
#define XUTIL_H
typedef void* Region;
typedef struct { short x, y; unsigned short width, height; } XRectangle;
#define XCreateRegion(...) NULL
#define XUnionRectWithRegion(...)
#define XDestroyRegion(...)
#endif
