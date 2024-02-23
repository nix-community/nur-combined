import os
print(os.environ['LD_LIBRARY_PATH'])

import torch
from transformers import Wav2Vec2Processor, Wav2Vec2ForCTC
import io
from urllib.parse import parse_qs
import torchaudio
import tempfile
from pathlib import Path

INFERENCE_BLOCK_SECONDS = 5
MODEL = 'alefiury/wav2vec2-large-xlsr-53-coraa-brazilian-portuguese-gain-normalization'
DEVICE = 'cuda'
SOCKET_TIMEOUT = 60

def handler():
    device = torch.device(DEVICE)

    model = Wav2Vec2ForCTC.from_pretrained(MODEL).to(device)
    processor = Wav2Vec2Processor.from_pretrained(MODEL)
    def _handle(self):
        try:
            logger.info('request started')
            data = self.rfile.read(int(self.headers.get('content-length')))
            tempfile_audio = tempfile.mktemp()
            Path(tempfile_audio).write_bytes(data)
            audio, sr = torchaudio.load(tempfile_audio, backend='ffmpeg')
            audio = torchaudio.functional.resample(audio, sr, 16000); sr = 16000
            audio = torch.mean(audio, axis=0) # convert to mono
            samples = audio.shape[0]
            logger.info('torchaudio loaded')
            block_size = sr * INFERENCE_BLOCK_SECONDS # n segundos
            last_sample_block = samples - (samples % block_size)
            ret = []
            text = ""
            for (a, b) in zip(
              range(0, samples, block_size),
              [*range(block_size, samples, block_size), -1]
             ):
                b_candidate = b + int(sr/2)
                if b > 0 and b_candidate <= samples:
                    b = b_candidate

                audio_patch = audio[a:b]
                features = processor(audio_patch, sampling_rate=sr, padding=True, return_tensors='pt')
                input_values = features.input_values.to(device)
                attention_mask = features.attention_mask.to(device)
                predicted = []
                with torch.no_grad():
                    logits = model(input_values, attention_mask=attention_mask).logits
                pred_ids = torch.argmax(logits, dim=-1)
                predicted = processor.batch_decode(pred_ids)
                predicted = predicted[0].strip()
                logger.info(f'predict {predicted}')
                text = text.strip()
                seconds = a//sr

                cut_point = 0
                for i in range(15):
                    if text[-i:] == predicted[:i]:
                        cut_point = i
                ret.append(dict(location=seconds, text=predicted[cut_point:]))
            logger.info(f'result: {ret}')
            return dict(data=ret)
        except Exception as e:
            return dict(error=str(e))
    return _handle
