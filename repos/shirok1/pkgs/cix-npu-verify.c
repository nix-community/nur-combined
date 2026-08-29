#define _POSIX_C_SOURCE 200809L

#include <npu/cix_noe_standard_api.h>
#include <errno.h>
#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

typedef struct {
    unsigned char *data;
    size_t size;
} buffer_t;

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

static buffer_t read_file(const char *path)
{
    buffer_t buffer = { 0 };
    FILE *file = fopen(path, "rb");
    if (!file || fseek(file, 0, SEEK_END) || (buffer.size = (size_t)ftell(file), fseek(file, 0, SEEK_SET))) {
        fprintf(stderr, "cannot open %s: %s\n", path, strerror(errno));
        if (file)
            fclose(file);
        return buffer;
    }
    buffer.data = malloc(buffer.size ? buffer.size : 1);
    if (!buffer.data || fread(buffer.data, 1, buffer.size, file) != buffer.size) {
        fprintf(stderr, "cannot read %s\n", path);
        free(buffer.data);
        buffer.data = NULL;
    }
    fclose(file);
    return buffer;
}

static int get_descriptors(noe_context_t context, noe_graph_id_t graph, tensor_type_t type,
                           tensor_desc_t **descriptors, uint32_t *count, size_t *total)
{
    if (!noe_ok(context, noe_get_tensor_count(context, graph, type, count), "query tensor count"))
        return 0;
    *descriptors = calloc(*count, sizeof(**descriptors));
    if (!*descriptors)
        return 0;
    for (uint32_t i = 0; i < *count; ++i) {
        if (!noe_ok(context, noe_get_tensor_descriptor(context, graph, type, i, &(*descriptors)[i]),
                    "query tensor descriptor"))
            return 0;
        *total += (*descriptors)[i].size;
        printf("%s[%u]: %u bytes, type=%u, scale=%g, zero_point=%d\n",
               type == NOE_TENSOR_TYPE_INPUT ? "input" : "output", i, (*descriptors)[i].size,
               (unsigned int)(*descriptors)[i].data_type, (*descriptors)[i].scale,
               (*descriptors)[i].zero_point);
    }
    return 1;
}

static size_t compare_output(const unsigned char *actual, const unsigned char *expected,
                             const tensor_desc_t *descriptor, float atol, float rtol,
                             float *max_absolute, float *max_relative)
{
    if (descriptor->data_type != NOE_DATA_TYPE_F32) {
        size_t mismatches = 0;
        for (uint32_t i = 0; i < descriptor->size; ++i)
            mismatches += actual[i] != expected[i];
        return mismatches;
    }

    size_t mismatches = 0;
    for (uint32_t offset = 0; offset < descriptor->size; offset += sizeof(float)) {
        float got, want;
        memcpy(&got, actual + offset, sizeof(got));
        memcpy(&want, expected + offset, sizeof(want));
        if (isnan(got) && isnan(want))
            continue;
        float absolute = fabsf(got - want);
        float relative = absolute / fmaxf(fabsf(want), 1e-30f);
        *max_absolute = fmaxf(*max_absolute, absolute);
        *max_relative = fmaxf(*max_relative, relative);
        mismatches += !isfinite(absolute) || absolute > atol + rtol * fabsf(want);
    }
    return mismatches;
}

static void usage(const char *program)
{
    fprintf(stderr, "usage: %s MODEL.cix INPUT.bin GOLDEN.bin [--runs N] [--atol X] [--rtol X]\n",
            program);
}

static int self_test(void)
{
    const float expected[] = { 1.0f, -2.0f };
    const float close[] = { 1.0005f, -2.0f };
    const float far[] = { 1.1f, -2.0f };
    tensor_desc_t descriptor = { .size = sizeof(expected), .data_type = NOE_DATA_TYPE_F32 };
    float max_absolute = 0, max_relative = 0;
    int ok = compare_output((const unsigned char *)close, (const unsigned char *)expected,
                            &descriptor, 1e-3f, 0, &max_absolute, &max_relative) == 0 &&
             compare_output((const unsigned char *)far, (const unsigned char *)expected,
                            &descriptor, 1e-3f, 0, &max_absolute, &max_relative) == 1;
    puts(ok ? "self-test: PASS" : "self-test: FAIL");
    return ok ? 0 : 1;
}

int main(int argc, char **argv)
{
    unsigned long runs = 1000;
    float atol = 1e-4f, rtol = 1e-3f;
    if (argc == 2 && !strcmp(argv[1], "--self-test"))
        return self_test();
    if (argc < 4) {
        usage(argv[0]);
        return 2;
    }
    for (int i = 4; i < argc; i += 2) {
        if (i + 1 == argc) {
            usage(argv[0]);
            return 2;
        }
        char *end;
        errno = 0;
        if (!strcmp(argv[i], "--runs")) {
            runs = strtoul(argv[i + 1], &end, 10);
            if (errno || *end || !runs)
                goto invalid_argument;
        } else if (!strcmp(argv[i], "--atol") || !strcmp(argv[i], "--rtol")) {
            float value = strtof(argv[i + 1], &end);
            if (errno || *end || value < 0 || !isfinite(value))
                goto invalid_argument;
            *(argv[i][2] == 'a' ? &atol : &rtol) = value;
        } else {
            goto invalid_argument;
        }
    }

    buffer_t input = read_file(argv[2]);
    buffer_t golden = read_file(argv[3]);
    if (!input.data || !golden.data)
        return 1;

    noe_context_t context = NULL;
    noe_graph_id_t graph = 0;
    noe_job_id_t job = 0;
    job_config_npu_t npu_config = { 0 };
    job_config_t job_config = { .conf_j_npu = &npu_config };
    tensor_desc_t *inputs = NULL, *outputs = NULL;
    uint32_t input_count = 0, output_count = 0;
    size_t input_size = 0, output_size = 0;
    unsigned char *actual = NULL;
    int ok = noe_ok(context, noe_init_context(&context, NOE_DEVICE_AIPU), "initialize context") &&
             noe_ok(context, noe_load_graph(context, argv[1], &graph, NULL), "load graph") &&
             get_descriptors(context, graph, NOE_TENSOR_TYPE_INPUT, &inputs, &input_count, &input_size) &&
             get_descriptors(context, graph, NOE_TENSOR_TYPE_OUTPUT, &outputs, &output_count, &output_size);

    if (ok && (input.size != input_size || golden.size != output_size)) {
        fprintf(stderr, "file size mismatch: input %zu/%zu bytes, golden %zu/%zu bytes\n",
                input.size, input_size, golden.size, output_size);
        ok = 0;
    }
    if (ok) {
        actual = malloc(output_size ? output_size : 1);
        ok = actual && noe_ok(context, noe_create_job(context, graph, &job, &job_config), "create job");
    }

    size_t input_offset = 0;
    for (uint32_t i = 0; ok && i < input_count; ++i) {
        ok = noe_ok(context, noe_load_tensor(context, job, i, input.data + input_offset), "load input");
        input_offset += inputs[i].size;
    }

    struct timespec start, finish;
    size_t mismatches = 0;
    float max_absolute = 0, max_relative = 0;
    if (ok)
        clock_gettime(CLOCK_MONOTONIC, &start);
    for (unsigned long run = 0; ok && run < runs; ++run) {
        ok = noe_ok(context, noe_job_infer_sync(context, job, -1), "run inference");
        size_t output_offset = 0;
        for (uint32_t i = 0; ok && i < output_count; ++i) {
            ok = noe_ok(context, noe_get_tensor(context, job, NOE_TENSOR_TYPE_OUTPUT, i,
                                                actual + output_offset), "read output");
            if (ok)
                mismatches += compare_output(actual + output_offset, golden.data + output_offset,
                                             &outputs[i], atol, rtol, &max_absolute, &max_relative);
            output_offset += outputs[i].size;
        }
        if (mismatches) {
            fprintf(stderr, "run %lu failed with %zu mismatched values/bytes\n", run + 1, mismatches);
            ok = 0;
        }
    }
    if (ok) {
        clock_gettime(CLOCK_MONOTONIC, &finish);
        double milliseconds = (finish.tv_sec - start.tv_sec) * 1000.0 +
                              (finish.tv_nsec - start.tv_nsec) / 1000000.0;
        printf("PASS: %lu runs, max_abs=%g, max_rel=%g, mean=%.3f ms\n",
               runs, max_absolute, max_relative, milliseconds / runs);
    }

    if (job)
        noe_clean_job(context, job);
    if (graph)
        noe_unload_graph(context, graph);
    if (context)
        noe_deinit_context(context);
    free(actual);
    free(outputs);
    free(inputs);
    free(golden.data);
    free(input.data);
    return ok ? 0 : 1;

invalid_argument:
    fprintf(stderr, "invalid value for %s: %s\n", argv[argc - 2], argv[argc - 1]);
    usage(argv[0]);
    return 2;
}
