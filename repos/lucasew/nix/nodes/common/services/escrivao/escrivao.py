#!/usr/bin/env -S sd nix shell
#!nix-shell -i python3 -p python3PackagesBin.python-telegram-bot
#! vim: syntax=python

# Telegram bot to transcribe audio files to text. Based on: https://github.com/alefiury/SE-R_2022_Challenge_Wav2vec2

from pathlib import Path
from argparse import ArgumentParser
import os
import logging
import gc
import traceback
import sys

logging.basicConfig(level=logging.INFO)
logging.getLogger("httpx").setLevel(logging.WARNING)
logger = logging.getLogger(__name__)


import telegram
from telegram import Update
from telegram.ext import Application, filters, MessageHandler
from telegram.constants import ChatAction
import httpx

parser = ArgumentParser()
parser.add_argument('-t', '--token', type=Path, required=True)
parser.add_argument('--worker-socket', type=Path, default=Path("/run/python-microservices/stt-ptbr"))
args = parser.parse_args()

TELEGRAM_TOKEN = args.token.read_text().strip()

backend_transport = httpx.HTTPTransport(uds=str(args.worker_socket))
client = httpx.Client(transport=backend_transport)

class BackendException(Exception):
    pass

class Timestamp:
    def __init__(self, seconds: int):
        self.seconds = int(seconds)
    def __str__(self):
        minutes = self.seconds // 60
        hours = minutes // 60
        minutes = minutes % 60
        seconds = self.seconds % 60
        return f"{hours}:{minutes:02d}:{seconds:02d}"
    def __add__(self, value):
        return Timestamp(self.seconds + int(value))

async def inference(audio):
    inference_response = client.send(httpx.Request('GET', 'http://a', content=audio))
    data = inference_response.json()
    if 'error' in data:
        raise BackendException(data['error'])
    if 'data' in data:
        data = data['data']
    text = ''
    for chunk in data:
        print(chunk, file=sys.stderr)
        timestamp = Timestamp(chunk['location'])
        chunk_text = chunk['text']
        text = f"{text}\n({timestamp}) {chunk_text}"
    return f"""
{text}

~Escrivão by https://github.com/lucasew based on https://github.com/alefiury/SE-R_2022_Challenge_Wav2vec2
    """.strip()
    
async def handle_audio(update: Update, context):
    items = [
        update.message.audio,
        update.message.document,
        update.message.voice
    ]
    for item in items:
        if item is None:
            continue
        await update.message.chat.send_action(ChatAction.TYPING)
        file = await item.get_file()
        if file.file_size >= 20*1024*1024:
            await update.message.reply_text("Erro: arquivo grande demais. Limite: 20MB", reply_to_message_id=update.message.id)
            continue
        try:
            audio_bytes = await file.download_as_bytearray()
            audio_bytes = bytes(audio_bytes)
            # print(audio_bytes)
            text = await inference(audio_bytes)
            await update.message.reply_text(text, reply_to_message_id=update.message.id)
            logger.info(f'audio ({update.message.chat.title}/{update.message.chat.username}-{update.message.chat.id}) {text}')
        except Exception as e:
            print(e)
            traceback.print_exc()
            await update.message.reply_text(f"Erro: {e}")

app = Application.builder().token(TELEGRAM_TOKEN).build()
app.add_handler(MessageHandler(filters.AUDIO | filters.VOICE, handle_audio))
app.run_polling(allowed_updates=Update.MESSAGE)

