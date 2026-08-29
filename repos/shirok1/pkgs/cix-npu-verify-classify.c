#define _POSIX_C_SOURCE 200809L
#define STB_IMAGE_IMPLEMENTATION
#define STB_IMAGE_RESIZE_IMPLEMENTATION

#include <npu/cix_noe_standard_api.h>
#include <stb_image.h>
#include <stb_image_resize.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#ifndef IMAGENET_LABELS
#error IMAGENET_LABELS must name the ImageNet label file
#endif

static int noe_ok(noe_context_t context, noe_status_t status, const char *operation)
{
    if (status == NOE_STATUS_SUCCESS)
        return 1;
    const char *message = NULL;
    if (context)
        noe_get_error_message(context, status, &message);
    fprintf(stderr, "%s failed: %s (NOE status %#x)\n", operation,
            message ? message : "unknown error", (unsigned int)status);
    return 0;
}

static int8_t *prepare_image(const char *path, const tensor_desc_t *descriptor)
{
    int width, height, channels;
    unsigned char *image = stbi_load(path, &width, &height, &channels, 3);
    if (!image) {
        fprintf(stderr, "cannot decode %s: %s\n", path, stbi_failure_reason());
        return NULL;
    }

    int resized_width = width < height ? 256 : (width * 256 + height / 2) / height;
    int resized_height = height <= width ? 256 : (height * 256 + width / 2) / width;
    unsigned char *resized = malloc((size_t)resized_width * resized_height * 3);
    int8_t *tensor = malloc(3 * 224 * 224);
    if (!resized || !tensor ||
        !stbir_resize_uint8_srgb(image, width, height, 0, resized, resized_width, resized_height, 0,
                                3, STBIR_ALPHA_CHANNEL_NONE, 0)) {
        fprintf(stderr, "cannot resize image\n");
        free(tensor);
        tensor = NULL;
    }

    if (tensor) {
        static const float mean[] = { 123.68f, 116.78f, 103.94f };
        int left = (resized_width - 224) / 2;
        int top = (resized_height - 224) / 2;
        for (int channel = 0; channel < 3; ++channel)
            for (int y = 0; y < 224; ++y)
                for (int x = 0; x < 224; ++x) {
                    unsigned char pixel = resized[((top + y) * resized_width + left + x) * 3 + channel];
                    long value = lrintf(((float)pixel - mean[channel]) * descriptor->scale) +
                                 descriptor->zero_point;
                    if (value < INT8_MIN)
                        value = INT8_MIN;
                    if (value > INT8_MAX)
                        value = INT8_MAX;
                    tensor[(channel * 224 + y) * 224 + x] = (int8_t)value;
                }
    }

    free(resized);
    stbi_image_free(image);
    return tensor;
}

static int load_labels(char storage[1000][96])
{
    FILE *file = fopen(IMAGENET_LABELS, "r");
    if (!file)
        return 0;
    int count = 0;
    while (count < 1000 && fgets(storage[count], sizeof(storage[count]), file)) {
        storage[count][strcspn(storage[count], "\r\n")] = '\0';
        ++count;
    }
    fclose(file);
    return count == 1000;
}

static void print_top(const int8_t scores[1000], const tensor_desc_t *descriptor, unsigned int top)
{
    char labels[1000][96];
    if (!load_labels(labels)) {
        fputs("cannot read ImageNet labels\n", stderr);
        return;
    }

    double probabilities[1000], total = 0;
    int highest = scores[0];
    for (int i = 1; i < 1000; ++i)
        if (scores[i] > highest)
            highest = scores[i];
    for (int i = 0; i < 1000; ++i)
        total += probabilities[i] = exp(((double)scores[i] - highest) / descriptor->scale);

    for (unsigned int rank = 0; rank < top; ++rank) {
        int best = 0;
        for (int i = 1; i < 1000; ++i)
            if (probabilities[i] > probabilities[best])
                best = i;
        printf("%u. %-32s %6.2f%%\n", rank + 1, labels[best], probabilities[best] * 100 / total);
        probabilities[best] = -1;
    }
}

int main(int argc, char **argv)
{
    unsigned long top = 5;
    if (argc != 3 && argc != 5) {
        fprintf(stderr, "usage: %s MODEL.cix IMAGE [--top N]\n", argv[0]);
        return 2;
    }
    if (argc == 5) {
        char *end;
        top = strtoul(argv[4], &end, 10);
        if (strcmp(argv[3], "--top") || *end || top < 1 || top > 1000) {
            fputs("--top must be between 1 and 1000\n", stderr);
            return 2;
        }
    }

    noe_context_t context = NULL;
    noe_graph_id_t graph = 0;
    noe_job_id_t job = 0;
    job_config_npu_t npu_config = { 0 };
    job_config_t job_config = { .conf_j_npu = &npu_config };
    tensor_desc_t input_descriptor, output_descriptor;
    uint32_t input_count, output_count;
    int8_t output[1000], *input = NULL;

    int ok = noe_ok(context, noe_init_context(&context, NOE_DEVICE_AIPU), "initialize context") &&
             noe_ok(context, noe_load_graph(context, argv[1], &graph, NULL), "load graph") &&
             noe_ok(context, noe_get_tensor_count(context, graph, NOE_TENSOR_TYPE_INPUT, &input_count),
                    "query input count") &&
             noe_ok(context, noe_get_tensor_count(context, graph, NOE_TENSOR_TYPE_OUTPUT, &output_count),
                    "query output count") &&
             noe_ok(context, noe_get_tensor_descriptor(context, graph, NOE_TENSOR_TYPE_INPUT, 0,
                                                       &input_descriptor), "query input") &&
             noe_ok(context, noe_get_tensor_descriptor(context, graph, NOE_TENSOR_TYPE_OUTPUT, 0,
                                                       &output_descriptor), "query output");
    if (ok && (input_count != 1 || output_count != 1 || input_descriptor.size != 3 * 224 * 224 ||
               input_descriptor.data_type != NOE_DATA_TYPE_S8 || output_descriptor.size != 1000 ||
               output_descriptor.data_type != NOE_DATA_TYPE_S8)) {
        fputs("model is not the expected INT8 ImageNet ResNet50\n", stderr);
        ok = 0;
    }
    if (ok)
        ok = (input = prepare_image(argv[2], &input_descriptor)) != NULL &&
             noe_ok(context, noe_create_job(context, graph, &job, &job_config), "create job") &&
             noe_ok(context, noe_load_tensor(context, job, 0, input), "load image");

    struct timespec start, finish;
    if (ok) {
        clock_gettime(CLOCK_MONOTONIC, &start);
        ok = noe_ok(context, noe_job_infer_sync(context, job, -1), "run inference");
        clock_gettime(CLOCK_MONOTONIC, &finish);
    }
    if (ok)
        ok = noe_ok(context, noe_get_tensor(context, job, NOE_TENSOR_TYPE_OUTPUT, 0, output), "read output");
    if (ok) {
        double milliseconds = (finish.tv_sec - start.tv_sec) * 1000.0 +
                              (finish.tv_nsec - start.tv_nsec) / 1000000.0;
        printf("inference: %.3f ms\n", milliseconds);
        print_top(output, &output_descriptor, (unsigned int)top);
    }

    if (job)
        noe_clean_job(context, job);
    if (graph)
        noe_unload_graph(context, graph);
    if (context)
        noe_deinit_context(context);
    free(input);
    return ok ? 0 : 1;
}
