#include <npu/cix_noe_standard_api.h>
#include <stdio.h>

int main(void)
{
    noe_context_t context = NULL;
    noe_status_t result = noe_init_context(&context, NOE_DEVICE_AIPU);
    if (result != NOE_STATUS_SUCCESS) {
        fprintf(stderr, "failed to initialize NPU (NOE status %#x)\n", result);
        return 1;
    }

    noe_device_status_t status;
    result = noe_get_device_status(context, &status);
    noe_deinit_context(context);

    if (result != NOE_STATUS_SUCCESS) {
        fprintf(stderr, "failed to query NPU (NOE status %#x)\n", result);
        return 1;
    }

    const char *names[] = { "idle", "busy", "exception" };
    puts(status <= NOE_DEV_EXCEPTION ? names[status] : "unknown");
    return 0;
}
