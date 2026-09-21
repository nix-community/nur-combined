#ifndef XLIB_H
#define XLIB_H
typedef void* Display;
typedef unsigned long Window;
#define XDestroyWindow(...)
#define XResizeWindow(...)
#define XCreateSimpleWindow(...) 0
#define DefaultRootWindow(...) 0
#define XReparentWindow(...)
#define XMapWindow(...)
#endif
