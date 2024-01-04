#!/usr/bin/env -S sd nix shell
#!nix-shell -i python3 -p python3PackagesBin.matplotlib python3PackagesBin.facenet-pytorch python3PackagesBin.tqdm python3PackagesBin.opencv4 python3PackagesBin.pandas python3PackagesBin.scikit-learn python3PackagesBin.streamlit

# The idea here is to cluster a set of images of faces
# ~stolen~ inspired from https://pyimagesearch.com/2018/07/09/face-clustering-with-python/
# demo dataset: https://www.kaggle.com/datasets/rawatjitesh/avengers-face-recognition

import faulthandler
faulthandler.enable()

import sys

print(sys.argv)
# import dlib
# dlib.get_frontal_face_detector()
# import face_recognition

import streamlit as st
from streamlit import runtime

if not runtime.exists():
    from streamlit.web import cli as stcli
    from shutil import which
    import os
    args=[which("streamlit"), 'run', __file__, '--', *sys.argv[1:]]
    print(args[0], args, flush=True)
    os.execvp(args[0], args)

from streamlit.runtime.scriptrunner.script_run_context import get_script_run_ctx

    
print(get_script_run_ctx())


from facenet_pytorch import MTCNN, InceptionResnetV1
from matplotlib import pyplot as plt



import cv2
from tqdm import tqdm
from pathlib import Path
import re
import numpy as np
import pandas as pd
from argparse import ArgumentParser
from sys import stderr, stdout
import torch

print("chegou AAAAA")


device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
print(f"pytorch device: {device}", file=stderr)

mtcnn = MTCNN(
    image_size=160, margin=0, min_face_size=20,
    thresholds=[0.6, 0.7, 0.7], factor=0.709, post_process=True,
    device=device
)

camera_img = st.camera_input("Tire uma foto")

if camera_img is not None:
    # st.image(camera_img)
    buffer = camera_img.getvalue()
    # print(camera_img, buffer)
    image = cv2.imdecode(np.frombuffer(buffer, np.uint8), cv2.IMREAD_COLOR)
    image = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
    for bbx, prob in zip(*mtcnn.detect(image)):
        (xi, yi, xf, yf) = map(int, bbx)
        image = cv2.rectangle(image, (xi, yi), (xf, yf), (255, 0, 0), 2)
        print(bbx, prob)
    st.image(image)
