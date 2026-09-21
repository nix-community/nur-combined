#ifndef VULKAN_WAYLAND_H
#define VULKAN_WAYLAND_H
#include <vulkan/vulkan.h>
typedef struct VkWaylandSurfaceCreateInfoKHR {
    int sType;
    void* display;
    void* surface;
} VkWaylandSurfaceCreateInfoKHR;
#define VK_STRUCTURE_TYPE_WAYLAND_SURFACE_CREATE_INFO_KHR 0
#define vkCreateWaylandSurfaceKHR(...) VK_ERROR_EXTENSION_NOT_PRESENT
#endif
