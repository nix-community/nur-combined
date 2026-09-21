#ifndef VULKAN_XLIB_H
#define VULKAN_XLIB_H
#include <vulkan/vulkan.h>
typedef void* Display;
typedef unsigned long Window;
typedef struct VkXlibSurfaceCreateInfoKHR {
    int sType;
    const void* pNext;
    int flags;
    Display* dpy;
    Window window;
} VkXlibSurfaceCreateInfoKHR;
#define VK_STRUCTURE_TYPE_XLIB_SURFACE_CREATE_INFO_KHR 0
#define vkCreateXlibSurfaceKHR(...) VK_ERROR_EXTENSION_NOT_PRESENT
#endif
