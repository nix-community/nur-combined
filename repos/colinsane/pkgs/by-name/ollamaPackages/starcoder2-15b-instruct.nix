# <https://ollama.com/library/starcoder2>
# "instruct" variant is 15b variant, trained to follow human instructions
{ mkOllamaModel }: mkOllamaModel {
  modelName = "starcoder2";
  variant = "15b-instruct";
  manifestHash = "sha256-d4CHl21nLx1AzVVuGWUZnQm6YM3plywFTWl3F2DUznw=";
  modelBlob = "4688154b6ed39a87f78adc8a7b31158f37280807c83704fcecdd4e2800404ae5";
  modelBlobHash = "sha256-RogVS27Tmof3ityKezEVjzcoCAfINwT87N1OKABASuU=";
  paramsBlob = "0aeac66f19bfe1d743f4e017141582f12a81cedb030e36f0e039569d66a5eebb";
  paramsBlobHash = "sha256-CurGbxm/4ddD9OAXFBWC8SqBztsDDjbw4DlWnWal7rs=";
  systemBlob = "708c319c4125641528576d2bec8da831260821965662ba89c802c803ebeeb2fa";
  systemBlobHash = "sha256-cIwxnEElZBUoV20r7I2oMSYIIZZWYrqJyALIA+vusvo=";
}
