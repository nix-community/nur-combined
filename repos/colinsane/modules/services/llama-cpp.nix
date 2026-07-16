# useful commands:
# - `curl http://10.0.10.22:11435/models | jq .`
# - `sudo radeontop`
# - `BUNPEN_DISABLE=1 sudo -E htop` (and view `GPU` column, to see usage)
#
# ## performance tuning:
# - run `llama-server --verbose ...`
# - GPU use (per htop) should be near 100% during the prompt processing (i.e. the first prompt after init).
#   - even for models larger than the GPU device ram, it seems.
# - check logs for: `load_tensors: offloaded NN/MM layers to GPU`
#
# ## docs
# - tool calling, chat templates: <https://github.com/ggml-org/llama.cpp/blob/master/docs/function-calling.md>
#
# ### using gpt-oss-20b (per <https://github.com/ggml-org/llama.cpp/discussions/15396>)
# - `-hf ggml-org/gpt-oss-20b-GGUF --ctx-size 0 --jinja -ub 2048 -b 2048 --n-cpu-moe 22`
# prompt eval: 307 tok/sec
# eval: 5-8 tok/sec (tends toward 8)
# it's largely compatible with claude 2.1.90; falls apart when trying to create .patch files (it comes close! but triggers API/parser error).
# llama_memory_breakdown_print: | memory breakdown [MiB]                 | total             free     self   model   context   compute    unaccounted |
# llama_memory_breakdown_print: |   - Vulkan0 (RX 5700 XT (RADV NAVI10)) |  8192 = 17592186044207 + ( 8396 =  2050 +    3132 +    3214) +           3 |
# llama_memory_breakdown_print: |   - Host                               |                           10368 = 10085 +       0 +     282                |
#
# ### using gpt-oss-120b (per <https://github.com/ggml-org/llama.cpp/discussions/15396>)
# - `-hf ggml-org/gpt-oss-120b-GGUF --ctx-size 65536 --jinja -ub 2048 -b 2048 --n-cpu-moe 37 --fit-target 128`
# prompt eval: 144 tok/sec
# eval: 3-5 tok/sec
# it's 100% compatible with claude 2.1.90; takes an hour to refactor a nix package & it can't create valid .patch files, but it knows to use sed instead.
# llama_memory_breakdown_print: | memory breakdown [MiB]                 | total   free     self   model   context   compute    unaccounted |
# llama_memory_breakdown_print: |   - Vulkan0 (RX 5700 XT (RADV NAVI10)) |  8192 = 1760 + ( 5558 =  1607 +    2394 +    1556) +         873 |
# llama_memory_breakdown_print: |   - Host                               |                 60428 = 59851 +       0 +     577                |
#
# ### using gemma-4-31B-it-Q4_K_M
# - `llama-server -hf ggml-org/gemma-4-31B-it-GGUF --ctx-size 65536`
# prompt eval: 24 tok/sec
# eval: 0.35 tok/sec
#
# ### using gemma-4-26B-A4B-it-UD-Q4_K_M
# -- ctx-size 65536
# prompt eval: 202 tok/sec
# eval: 12 tok/sec
# claude 2.1.90 + llama-cpp 8648 fail to parse its tool call
#
# ### using gemma-4-26B-A4B-it-UD-Q4_K_M --ctx-size 32768 --cache-type-k f16 --cache-type-k q8_0 --spec-type draft-mtp --spec-draft-n-max 3
# prompt eval: 104 tok/sec
#        eval:  20 tok/sec
# memory breakdown [MiB]                 | total   free     self   model   context   compute    unaccounted |
#   - Vulkan0 (RX 5700 XT (RADV NAVI10)) |  8192 =  208 + ( 7053 =  5622 +    1140 +     290) +         929 |
#   - Host                               |                 16077 = 16065 +       0 +      11                |
#
# ### using gemma-4-26B-A4B-it-MXFP4_MOE
# -- ctx-size 65536
# prompt eval: 151 tok/sec
# eval: 10 tok/sec
# claude 2.1.90 + llama-cpp 8648 fail to parse its tool call
#
# ### using gemma-4-26B-A4B-it-Q8_0
# -- ctx-size 65536
# prompt eval: 100 tok/sec
# eval: 16 tok/sec
# claude 2.1.90 + llama-cpp 8656 successfully parse *most* tool calls, but not the TaskUpdate call
#
# ### using gemma-4-e4b-it-q4_k_m (stock)
# --fit-target 128
# --ctx-size 105472
# prompt eval: 557 tok/sec
# eval: 56 tok/sec
#
# ### using gemma-4-e4b-it-q4_k_m (stock but quantized kv cache)
# --cache-type-k q8_0 --cache-type-v q8_0 --fit-target 128
# --ctx-size 128k (default)
# uses 6436 MiB of device memory
# prefill: 501 tok/sec
# eval: 35 tok/sec
#
# ### using gemma-4-e4b-it-q4_k_m --swa-full
# - on 8 GiB AMD GPU
# - --swa-full --cache-type-k q8_0 --cache-type-v q8_0 --fit-target 128
# - --ctx-size 36096 (derived)
# llama_memory_breakdown_print: | memory breakdown [MiB]                 | total   free    self   model   context   compute    unaccounted |
# llama_memory_breakdown_print: |   - Vulkan0 (RX 5700 XT (RADV NAVI10)) |  8192 =  151 + (6958 =  4731 +    1709 +     517) +        1082 |
# llama_memory_breakdown_print: |   - Host                               |                  511 =   360 +       0 +     151                |
# - --ubatch-size 128  => ctx-size rises to 44800
# - --ubatch-size 128 + --cache-type-{k,v} q4_0  => ctx-size rises to 48896
# - --ubatch-size 128 + no swa-full + no cache-type-{k,v}  => ctx-size rises to full 131072
#
# ### using gemma-4-12b-it-q3_k_m --fit-target 128 --cache-ram 32768 --ctx-checkpoints 128 --ubatch-size 128 --cache-type-k q8_0 --cache-type-v q8_0 --swa-full
# - --ctx-size 5376 (derived)
# - on 8 GiB AMD GPU
# - prompt eval: 191 tok/sec
# -        eval:  31 tok/sec
# - q4_k_m with same settings (but 4096 ctx) is largely CPU dispatch.
# - q4_k_s with same settings (but 4096 ctx) is largely CPU dispatch.
#
# ### using gemma-4-12b-it-q3_k_m --fit-target 128 --cache-ram 65536 --ubatch-size 128 --flash-attn on
# - --ctx-size 4096 (derived)
# - on 8 GiB AMD GPU
# - prompt eval: 161 tok/sec
# -        eval:  21 tok/sec
#   common_memory_breakdown_print: | memory breakdown [MiB]                 | total   free    self   model   context   compute    unaccounted |
#   common_memory_breakdown_print: |   - Vulkan0 (RX 5700 XT (RADV NAVI10)) |  8192 =  267 + (6395 =  5084 +    1248 +      62) +        1528 |
#   common_memory_breakdown_print: |   - Host                               |                  844 =   742 +      96 +       5                |
#
# ### using gemma-4-12b-it-q3_k_m --fit-target 128 --cache-ram 65536 --ubatch-size 128 --cache-type-k q5_1 --cache-type-v q5_1
# - --ctx-size 78592 (derived)
# - on 8 GiB AMD GPU
# - prompt eval: 150 tok/sec
# -        eval:  26 tok/sec
# memory breakdown [MiB]                 | total   free    self   model   context   compute    unaccounted |
#   - Vulkan0 (RX 5700 XT (RADV NAVI10)) |  8192 =   93 + (6437 =  5415 +     970 +      51) +        1661 |
#   - Host                               |                  437 =   412 +       0 +      25                |
# ...
# - --no-host: no change
# - --batch-size 128 (to match ubatch-size): no change in memory usage
#
# 
# ### using gemma-4-12b-it-q3_k_m --fit-target 128 --cache-ram 65536 --ubatch-size 64 --cache-type-k q5_1 --cache-type-v q5_1 --no-host --no-repack
# - --ctx-size 82688 (derived)
# - on 8 GiB AMD GPU
# - prompt eval: 156 tok/sec
# -        eval:  24 tok/sec
# memory breakdown [MiB]                 | total   free    self   model   context   compute    unaccounted |
#   - Vulkan0 (RX 5700 XT (RADV NAVI10)) |  8192 =   19 + (6436 =  5415 +     994 +      27) +        1735 |
#   - Host                               |                  426 =   412 +       0 +      13                |
#
# ### using gemma-4-12b-it-q3_k_m --fit-target 128 --cache-ram 65536 --ubatch-size 256 --cache-type-k q5_1 --cache-type-v q5_1
# - --ctx-size 70912 (derived)
# - on 8 GiB AMD GPU
# - prompt eval: 129 tok/sec
# -        eval:  30 tok/sec
# memory breakdown [MiB]                 | total   free    self   model   context   compute    unaccounted |
#   - Vulkan0 (RX 5700 XT (RADV NAVI10)) |  8192 =  163 + (6439 =  5415 +     925 +      98) +        1589 |
#   - Host                               |                  458 =   412 +       0 +      45                |
#
# ### using gemma-4-12b-it-q3_k_m --fit-target 128 --cache-ram 65536 --cache-type-k q5_1 --cache-type-v q5_1
# - --ctx-size 55296 (derived)
# - --ubatch-size 512 (implied)
# - on 8 GiB AMD GPU
# - prompt eval: 111 tok/sec
# -        eval:  29 tok/sec
# memory breakdown [MiB]                 | total   free    self   model   context   compute    unaccounted |
#   - Vulkan0 (RX 5700 XT (RADV NAVI10)) |  8192 =  228 + (6459 =  5415 +     864 +     180) +        1503 |
#   - Host                               |                  487 =   412 +       0 +      74                |
#
# ### using gemma-4-12b-it-q4_k_s --fit-target 128 --cache-ram 32768 --ctx-checkpoints 128 --ubatch-size 128 --cache-type-k q8_0 --cache-type-v q8_0 
# - --ctx-size 4096 (derived)
# - on 8 GiB AMD GPU
# - prompt eval: 144 tok/sec
# -        eval:  19 tok/sec
# - uses about 600% CPU during eval, v.s. minimal for q3_k_m.
#
# ### using gemma-4-12b-it-q4_k_m --fit-target 128 --cache-ram 32768 --ctx-checkpoints 128 --ubatch-size 128
# - --ctx-size 4096 (derived)
# - on 8 GiB amd gpu
# - prompt eval: 116 tok/sec
# -        eval:  15 tok/sec
# ...
# - NO cache quantization => seems to be important for eval speed once overflowing GPU

# ### using gemma-4-12b-it-q4_k_m --fit-target 128 --cache-ram 32768 --ctx-checkpoints 128 --ubatch-size 128
# - --ctx-size 8192
# - on 8 GiB amd gpu
# - prompt eval: 175 tok/sec
# -        eval:  13 tok/sec
#
# ### using gemma-4-12b-it-q4_k_m --fit-target 128 --cache-ram 65536 --ctx-checkpoints 128 --ubatch-size 128
# - --ctx-size 32768
# - on 8 GiB amd gpu
# - prompt eval: 120 tok/sec
# -        eval:  13 tok/sec
#
# increase ubatch-size to 256 => eval drops to 12 tok/sec
# decrease ubatch-size to 32 => prompt eval drops to 60 tok/sec
#
# ### using gemma-4-12b-it-iq4_xs --fit-target 128 --cache-ram 65536 --ctx-checkpoints 128 --ubatch-size 128
# - --ctx-size 4096 (derived)
# - on 8 GiB amd gpu
# - prompt eval: 60 tok/sec
# -        eval:  16 tok/sec
# ...
# v.s. 14 tok/sec for IQ4_NL
#
# ### using gemma-4-12b-it-iq3_xxs --fit-target 128 --cache-ram 65536 --ctx-checkpoints 128 --ubatch-size 128
# - --ctx-size 42752 (derived)
# - on 8 GiB amd gpu
# - prompt eval: 142 tok/sec
# -        eval:  33 tok/sec
# ...
# enabling `--swa-full` raises eval to 34 tok/sec but drops derived ctx-size to 5888
#
# ### using gemma-4-12b-it-iq3_xxs --fit-target 128 --cache-ram 65536 --ctx-checkpoints 128 --ubatch-size 128 --cache-type-k q8_0 --cache-type-v q8_0
# - --ctx-size 131072 (derived)
# - on 8 GiB amd gpu
# - prompt eval: 172 tok/sec
# -        eval:  35 tok/sec
#
# ### using gemma-4-12b-it-iq3_xxs --fit-target 128 --cache-ram 65536 --ubatch-size 128 --flash-attn on
# - --ctx-size 42752 (derived)
# - on 8 GiB amd gpu
# common_memory_breakdown_print: | memory breakdown [MiB]                 | total   free    self   model   context   compute    unaccounted |
# common_memory_breakdown_print: |   - Vulkan0 (RX 5700 XT (RADV NAVI10)) |  8192 =   27 + (6479 =  4409 +    2028 +      41) +        1684 |
# common_memory_breakdown_print: |   - Host                               |                  427 =   412 +       0 +      15                |
# - prompt eval: 172 tok/sec
# -        eval:  33 tok/sec
#
# ### using gemma-4-12b-it-iq3_xxs --fit-target 128 --cache-ram 65536 --ubatch-size 128 --flash-attn on --cache-type-k q8_0 --cache-type-v q8_0
# - --ctx-size 131072 (derived)
# - on 8 GiB amd gpu
# common_memory_breakdown_print: | memory breakdown [MiB]                 | total   free    self   model   context   compute    unaccounted |
# common_memory_breakdown_print: |   - Vulkan0 (RX 5700 XT (RADV NAVI10)) |  8192 =  250 + (6284 =  4409 +    1810 +      64) +        1656 |
# common_memory_breakdown_print: |   - Host                               |                  450 =   412 +       0 +      38                |
# - prompt eval: 165 tok/sec
# -        eval:  32 tok/sec
# ...
# - removing `flash-attn on`: NO CHANGE
#
# ### using gemma-4-12b-it-q3_k_s --fit-target 128 --cache-ram 65536 --ubatch-size 128 --cache-type-k q8_0 --cache-type-v q8_0 --flash-attn on
# - --ctx-size 93696 (derived)
# memory breakdown [MiB]                 | total   free    self   model   context   compute    unaccounted |
#   - Vulkan0 (RX 5700 XT (RADV NAVI10)) |  8192 =   96 + (6437 =  4882 +    1500 +      55) +        1657 |
#   - Host                               |                  441 =   412 +       0 +      28                |
# - prompt eval: 165 tok/sec
# -        eval:  28 tok/sec
#
# ### using gemma-4-12b-it-ud-q3_k_xl --fit-target 128 --cache-ram 65536 --ubatch-size 128 --cache-type-k q5_1 --cache-type-v q5_1
# - --ctx-size 29184 (derived)
# memory breakdown [MiB]                 | total   free    self   model   context   compute    unaccounted |
#   - Vulkan0 (RX 5700 XT (RADV NAVI10)) |  8192 =  208 + (6449 =  5728 +     681 +      39) +        1534 |
#   - Host                               |                  553 =   540 +       0 +      13                |
# - prompt eval: 201 tok/sec
# -        eval:  33 tok/sec
#
# ### using gemma-4-12b-it-ud-q3_k_xl --fit-target 128 --cache-ram 65536 --ubatch-size 128 --cache-type-k q8_0 --cache-type-v q5_1
# - --ctx-size 11008 (derived)
#  memory breakdown [MiB]                 | total   free    self   model   context   compute    unaccounted |
#    - Vulkan0 (RX 5700 XT (RADV NAVI10)) |  8192 =   31 + (6458 =  5728 +     694 +      35) +        1702 |
#    - Host                               |                  548 =   540 +       0 +       8                |
# - prompt eval: 153 tok/sec
# -        eval:  32 tok/sec
#
# ### using gemma-4-12b-it-ud-q3_k_xl --fit-target 128 --cache-ram 65536 --ubatch-size 64 --cache-type-k q8_0 --cache-type-v q5_1
# - --ctx-size 13312 (derived)
# memory breakdown [MiB]                 | total   free    self   model   context   compute    unaccounted |
#   - Vulkan0 (RX 5700 XT (RADV NAVI10)) |  8192 =  118 + (6457 =  5728 +     710 +      18) +        1616 |
#   - Host                               |                  545 =   540 +       0 +       5                |
# - prompt eval: 188 tok/sec
# -        eval:  33 tok/sec
#
#
# ### using nemotron-3-nano-30b-a3b
# - on 8 GiB AMD GPU
# - 32768 ctx-size
# - 128 fit-target
# - q8_0 kv cache
# - 8m to eval Claude Code prompt
# - 9 tok/sec after
#
# ### using Qwen3.5-9B-Claude-4.6-Opus-Reasoning-Distilled-v2:
# - on 8 GiB AMD GPU
# - 32768 ctx-size
# - 256 fit-target
# - 1m30s to eval Claude Code prompt
# - 41 tok/sec after
# - i think it got trapped in a loop? can't quite remember
#
# ### using Qwen3.5-9B-Claude-4.6-Opus-Reasoning-Distilled-Q3_K_M:
# - on 8 GiB AMD GPU
# - full 256K ctx-size
# - 128 fit-target
# - cache-type-kv: q8_0
# - 2m to eval Claude Code prompt inside work dir
# - 31 tok/sec after
# - got trapped in loops when i tried to use it @ work
#
# ### using Qwen3.5-9B-Q4_K_M:
# - on 8 GiB AMD GPU
# - 102400 ctx-size, IIRC
# - 128 fit-target
# - 128 ubatch
# - cache-type-kv: q8_0
# - took 15m + 3000 tokens to summarize the design for a toplevel code directory
# - 129 tok/sec prompt eval, 38 tok/sec normal eval
#
# ### using Qwen3.5-9B-Claude-4.6-Opus-Reasoning-Distilled-v2-Q4_K_M
# - --ctx-size 79616
# - --fit-target 128
# - --cache-type-{k,v} q8_0
# - --ubatch 512 (implied)
# - took 6m35s, end tok=56058 (of 79616), to summarize the design for a toplevel code directory
#
# ### llama-server --model Qwen3.5-9B-Claude-4.6-Opus-Reasoning-Distilled-Q3_K_M.gguf --ctx-size 65536 --fit-target 128 --swa-full
# llama_memory_breakdown_print: | memory breakdown [MiB]                 | total   free    self   model   context   compute    unaccounted |
# llama_memory_breakdown_print: |   - Vulkan0 (RX 5700 XT (RADV NAVI10)) |  8192 =  470 + (6725 =  3975 +    2249 +     501) +         996 |
# llama_memory_breakdown_print: |   - Host                               |                  560 =   416 +       0 +     144                |
# ... fairly speedy!
#
# ### llama-server --model Qwen3.5-9B-Claude-4.6-Opus-Reasoning-Distilled-v2-Q4_K_M.gguf --ctx-size 79616 --ubatch-size 512 --cache-type-k q8_0 --cache-type-v q8_0 --fit-target 128 --swa-full
#
# ### llama-server --model Qwen3.5-9B-Claude-4.6-Opus-Reasoning-Distilled-v2-Q4_K_M.gguf --ctx-size 96768 --ubatch-size 256 --cache-type-k q8_0 --cache-type-v q8_0 --fit-target 128 --swa-full
#
# ### llama-server --model Qwen3.5-9B-Claude-4.6-Opus-Reasoning-Distilled-v2-Q4_K_M.gguf --ctx-size 105472 --ubatch-size 128 --cache-type-k q8_0 --cache-type-v q8_0 --fit-target 128 --swa-full
# llama_memory_breakdown_print: | memory breakdown [MiB]                 | total   free    self   model   context   compute    unaccounted |
# llama_memory_breakdown_print: |   - Vulkan0 (RX 5700 XT (RADV NAVI10)) |  8192 =  355 + (6889 =  4812 +    1952 +     125) +         947 |
# llama_memory_breakdown_print: |   - Host                               |                  601 =   545 +       0 +      55                |
#
# ### llama-server --model Qwen3.5-9B-Q4_K_M --ctx-size 102400 --ubatch-size 128 --cache-type-k q8_0 --cache-type-v q8_0 --fit-target 128 --swa-full
# llama_memory_breakdown_print: | memory breakdown [MiB]                 | total   free    self   model   context   compute    unaccounted |
# llama_memory_breakdown_print: |   - Vulkan0 (RX 5700 XT (RADV NAVI10)) |  8192 =  357 + (6887 =  4861 +    1901 +     125) +         947 |
# llama_memory_breakdown_print: |   - Host                               |                  599 =   545 +       0 +      54                |
#
# ### llama-server --model Qwen3.5-9B-Claude-4.6-Opus-Reasoning-Distilled-v2-Q4_K_M.gguf --ctx-size 110336 --ubatch-size 64 --cache-type-k q8_0 --cache-type-v q8_0 --fit-target 128 --swa-full
# llama_memory_breakdown_print: | memory breakdown [MiB]                 | total   free    self   model   context   compute    unaccounted |
# llama_memory_breakdown_print: |   - Vulkan0 (RX 5700 XT (RADV NAVI10)) |  8192 =  278 + (6907 =  4812 +    2032 +      62) +        1005 |
# llama_memory_breakdown_print: |   - Host                               |                  574 =   545 +       0 +      28                |
#
# ### llama-server --model Qwen3.5-9B-Claude-4.6-Opus-Reasoning-Distilled-Q3_K_M.gguf --ctx-size 131072 --fit-target 128 --swa-full
# llama_memory_breakdown_print: | memory breakdown [MiB]                 | total   free    self   model   context   compute    unaccounted |
# llama_memory_breakdown_print: |   - Vulkan0 (RX 5700 XT (RADV NAVI10)) |  8192 =  531 + (6429 =  2774 +    2685 +     969) +        1230 |
# llama_memory_breakdown_print: |   - Host                               |                 3508 =  1617 +    1611 +     280                |
# ... single-digit token/sec. GPU utilization < 20%
#
# ### llama-server --model Qwen3.5-9B-Claude-4.6-Opus-Reasoning-Distilled-Q3_K_M.gguf --ctx-size 262144 --ubatch-size 128 --cache-type-k q8_0 --cache-type-v q8_0 --fit-target 128 --swa-full
# llama_memory_breakdown_print: | memory breakdown [MiB]                 | total   free    self   model   context   compute    unaccounted |
# llama_memory_breakdown_print: |   - Vulkan0 (RX 5700 XT (RADV NAVI10)) |  8192 =  351 + (6896 =  2142 +    4553 +     201) +         943 |
# llama_memory_breakdown_print: |   - Host                               |                  627 =   497 +       0 +     130                |
#
# ### llama-server --model Qwen3.5-9B-Claude-4.6-Opus-Reasoning-Distilled-Q2.gguf --ctx-size 95232 --fit-target 128 --swa-full --cache-ram 32768 --ctx-checkpoints 128
# llama_memory_breakdown_print: | memory breakdown [MiB]                 | total   free    self   model   context   compute    unaccounted |
# llama_memory_breakdown_print: |   - Vulkan0 (RX 5700 XT (RADV NAVI10)) |  8192 =  426 + (6819 =  3141 +    3177 +     501) +         946 |
# llama_memory_breakdown_print: |   - Host                               |                  520 =   318 +       0 +     202                |
#
# ### llama-server --model Qwen3.5-4B-Claude-4.6-Opus-Reasoning-Distilled-v2.gguf --ctx-size 112640 --fit-target 128 --swa-full --cache-ram 32768 --ctx-checkpoints 128   # Q4_K_M
# llama_memory_breakdown_print: | memory breakdown [MiB]                 | total   free    self   model   context   compute    unaccounted |
# llama_memory_breakdown_print: |   - Vulkan0 (RX 5700 XT (RADV NAVI10)) |  8192 =  463 + (6783 =  2572 +    3721 +     490) +         945 |
# llama_memory_breakdown_print: |   - Host                               |                  727 =   497 +       0 +     230                |
#
# ### llama-server --model Qwen3.5-4B-Claude-4.6-Opus-Reasoning-Distilled-Q3_K_M.gguf --ctx-size 125952 --fit-target 128 --swa-full --cache-ram 32768 --ctx-checkpoints 128
# llama_memory_breakdown_print: | memory breakdown [MiB]                 | total   free    self   model   context   compute    unaccounted |
# llama_memory_breakdown_print: |   - Vulkan0 (RX 5700 XT (RADV NAVI10)) |  8192 =  475 + (6769 =  2142 +    4137 +     490) +         947 |
# llama_memory_breakdown_print: |   - Host                               |                  753 =   497 +       0 +     256                |
#
# ### llama-server --model Qwen3.5-4B-Claude-4.6-Opus-Reasoning-Distilled-Q3_K_M.gguf --ctx-size 262144 --ubatch 128 --cache-type-k q8_0 --cache-type-v q8_0 --fit-target 128 --swa-full --cache-ram 32768 --ctx-checkpoints 128
# llama_memory_breakdown_print: | memory breakdown [MiB]                 | total   free    self   model   context   compute    unaccounted |
# llama_memory_breakdown_print: |   - Vulkan0 (RX 5700 XT (RADV NAVI10)) |  8192 =  347 + (6896 =  2142 +    4553 +     201) +         947 |
# llama_memory_breakdown_print: |   - Host                               |                  627 =   497 +       0 +     130                |
#
# ### llama-server --model Qwen3.5-4B-Claude-4.6-Opus-Reasoning-Distilled-Q3_K_S.gguf --ctx-size 131328 --fit-target 128 --swa-full --cache-ram 32768 --ctx-checkpoints 128
# llama_memory_breakdown_print: | memory breakdown [MiB]                 | total   free    self   model   context   compute    unaccounted |
# llama_memory_breakdown_print: |   - Vulkan0 (RX 5700 XT (RADV NAVI10)) |  8192 =  486 + (6758 =  1963 +    4305 +     490) +         947 |
# llama_memory_breakdown_print: |   - Host                               |                  763 =   497 +       0 +     266                |
#
# ### llama-server --model Qwen3.5-4B-Claude-4.6-Opus-Reasoning-Distilled-Q3_K_S.gguf --ctx-size 146688 --ubatch 128 --fit-target 128 --swa-full --cache-ram 32768 --ctx-checkpoints 128
# llama_memory_breakdown_print: | memory breakdown [MiB]                 | total   free    self   model   context   compute    unaccounted |
# llama_memory_breakdown_print: |   - Vulkan0 (RX 5700 XT (RADV NAVI10)) |  8192 =  258 + (6986 =  1963 +    4785 +     238) +         947 |
# llama_memory_breakdown_print: |   - Host                               |                  571 =   497 +       0 +      74                |
#
# ### llama-server --model Qwen3.5-4B-Claude-4.6-Opus-Reasoning-Distilled-Q3_K_S.gguf --ctx-size 262144 --ubatch 128 --cache-type-k q8_0 --cache-type-v q8_0 --fit-target 128 --swa-full --cache-ram 32768 --ctx-checkpoints 128
# llama_memory_breakdown_print: | memory breakdown [MiB]                 | total   free    self   model   context   compute    unaccounted |
# llama_memory_breakdown_print: |   - Vulkan0 (RX 5700 XT (RADV NAVI10)) |  8192 =  526 + (6718 =  1963 +    4553 +     201) +         947 |
# llama_memory_breakdown_print: |   - Host                               |                  627 =   497 +       0 +     130                |
#
# ### llama-server --model Qwen3.5-27B-Claude-4.6-Opus-Reasoning-Distilled-v2-Q4_K_M.gguf --ctx-size 65536 --fit-target 128 --swa-full
# llama_params_fit_impl: projected to use 20519 MiB of device memory
#
# ### llama-server --model Qwen3.5-27B-Claude-4.6-Opus-Reasoning-Distilled-v2-Q4_K_M.gguf --ctx-size 65536 --fit-target 128 --swa-full
# llama_params_fit_impl: projected to use 24807 MiB of device memory
#
# ### llama-server --model Qwen3.5-27B-Claude-4.6-Opus-Reasoning-Distilled-v2-Q4_K_M.gguf --ctx-size 1048576 --fit-target 128 --swa-full
# llama_params_fit_impl: projected to use 84417 MiB of device memory
{ config, lib, pkgs, ... }:
let
  cfg = config.sane.services.llama-cpp;
in
{
  options.sane.services.llama-cpp = {
    enable = lib.mkEnableOption "llama-cpp LLM server";
  };

  config = lib.mkIf (cfg.enable && config.sane.maxBuildCost >= 2) {
    services.llama-cpp.enable = true;
    services.llama-cpp.package = pkgs.llama-cpp-vulkan;
    # services.llama-cpp.package = pkgs.llama-cpp.override { cpuArchDynamicDispatch = false; vulkanSupport = true; };
    # services.llama-cpp.package = pkgs.llama-cpp-vulkan.overrideAttrs (prevAttrs: {
    #   version = lib.warnIf (lib.versionOlder "9821" prevAttrs.version) "llama-cpp is updated upstream: remove version override?" "9821";
    #   src = prevAttrs.src.overrideAttrs {
    #     hash = "sha256-gkE3weJIQGDaGgVPRok+I08n1HfGD9tnugy7HBdlqCs=";
    #   };
    #   npmDepsHash = "sha256-X1DZgmhS/zHTqDT5zq0kywwntthcJ9vRXeqyO3zz6UU=";
    #   # postPatch = "";
    # });
    services.llama-cpp.settings = {
      verbose = true;
      host = config.sane.hosts.by-name."${config.networking.hostName}".wg-home.ip;
      # port: default is 8080, conflict-prone.
      # ollama default is 11434. hence 11435, as the successor.
      port = 11435;
      models-dir = toString pkgs.llama-cpp-models;

      # XXX(2026-04-01): if omitted, llama-cpp will attempt the model's native context, and decrease until it fits into RAM.
      # ctx-size = 131072;
      # ctx-size = 65536;
      # fit-target: how many MiB to leave free, for unexpected allocations (default 1024 MiB)
      fit-target = 128;
      # fit-ctx: never reduce context below this level when fitting to ram
      # fit-ctx = 32768;
      fit-ctx = 131072;
      # swa-full seems to allow much faster prompt evals after the first system prompt is cached,
      # but not always supported by model -- check logs:
      # > srv    load_model: swa_full is not supported by this model, it will be disabled
      # swa-full = true;
      cache-ram = 32768;  #< prompt cache (applies iff swa-full not supported by model?). default is 8192 (MiB)
      # ctx-checkpoints = 128;  #< experimental. each checkpoint is 50 MiB. defaults to 32 checkpoints.
      # ubatch-size is how many tokens to process simultaneously?
      # default: 512. higher values generally increase throughput, but also increase memory use.
      ubatch-size = 128;
      # cache-type-{k,v}: f32, f16, bf16, q8_0, q4_0, q4_1, iq4_nl (unsupported), q5_0, q5_1 (default: f16)
      # this refers to quantization of the k -> v (attention) cache.
      # quantizing k would seem to have larger effect than quantizing v.
      # jury's out on how much quantization degrades the model, however one would expect it to get worse as the context gets longer because it's recursive over all previous tokens.
      # <https://github.com/ggml-org/llama.cpp/discussions/20969#discussioncomment-16388331>
      # cache-k,v = f16,q8_0: used for 1 session. even this is enough to corrupt file paths (they become non-english): avoid.
      # cache-k,v = f16,q5_1: no data.
      # cache-k,v = q8_0,q8_0: no data.
      # cache-k,v = q8_0,q5_1: used for 1 session. started looping after 5~8k tokens.
      # cache-k,v = q5_1,q5_1: maybe a slight bias toward looping?
      # cache-type-k = "f16";
      # cache-type-v = "q8_0";
      no-warmup = true;  #< faster load -> eval, by not feeding it a dummy prompt on load
      no-mmproj = true;  #< don't load vision weights
      # parallel = 1;

      # coherence (keep the model from becoming pathological)
      # in actuality, tweaking DRY settings seems to induce typos in non-quantized models!
      # "--dry-multiplier" "0.6"  # how much influence the Don't Repeat Yourself filter has on overall token output (?)
      # "--dry-base" "2.0"  #< exponential penalization ramp
      # "--dry-penalty-last-n" "512"
      # "--dry-sequence-breaker" "none"
      # "--dry-penalty-last-n" "512"
      # "--reasoning-budget" "1536"  #< new models sometimes get stuck in <thought>...</thought> loops: force a maximum.
      # "--reasoning-format" "none"  #< disable server-side parsing of <thought>...</thought>; let them show up inline.

      # TODO: potential performance optimizations:
      # "--slot-save-path" "PATH"  # persist KV cache to disk
      # "--lookup-cache-dynamic" "FNAME"
      # "--flash-attn" [on|off|auto]
      # "--no-kv-offload"  #< XXX(2026-04-01) this would SIGNIFICANTLY reduce GPU memory usage, but breaks Claude tool use: "failed to parse grammar".
      # "--spec-default"  # speculative decoding
      # "--no-host"
      # "--no-repack"
    };

    users.groups.llama-cpp = {};

    users.users.llama-cpp = {
      group = "llama-cpp";
      isSystemUser = true;
    };

    systemd.services.llama-cpp.serviceConfig.DynamicUser = lib.mkForce false;  #< not required, but DynamicUser is confusing
    systemd.services.llama-cpp.serviceConfig.User = "llama-cpp";
    systemd.services.llama-cpp.environment.MESA_SHADER_CACHE_DIR = "/var/cache/llama-cpp";
    # networking isn't required for anything but accepting client connections (wireguard),
    # or, maybe, downloading models.
    systemd.services.llama-cpp.serviceConfig.IPAddressDeny = "any";
    systemd.services.llama-cpp.serviceConfig.IPAddressAllow = [
      "10.0.10.0/24"
      "127.0.0.1"
    ];

    sane.persist.sys.byStore.private = [
      # mesa_shader_cache/ and radv_builtin_shaders/
      # otherwise these take a solid 10 minutes to build on first run!
      { user = "llama-cpp"; group = config.users.users.llama-cpp.group; path = "/var/cache/llama-cpp"; method = "bind"; }
    ];

    sane.ports.ports."11435" = {
      protocol = [ "tcp" ];
      visibleTo.lan = true;  #< TODO: restrict to just wireguard clients
      description = "colin-llama-cpp";
    };
  };
}
