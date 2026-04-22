{
  lib,
  python,
  fetchFromGitHub,

  deepgram-captions,
  deepgram-sdk,
  ten-vad,
  huggingface-hub,
  accelerate,
  zhconv,
}:

python.pkgs.buildPythonApplication (finalAttrs: {
  pname = "pyvideotrans";
  version = "3.99";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "jianchang512";
    repo = "pyvideotrans";
    tag = "v${finalAttrs.version}";
    hash = "sha256-8Ts4ovHnGofiuIluwiJ7SgDM6FScl+T0yk63swTVq6c=";
  };

  postPatch = ''
    # fix: error: Multiple top-level packages discovered in a flat-layout: ['models', 'ffmpeg', 'videotrans'].
    cat >>pyproject.toml <<'EOF'
    [tool.setuptools.packages.find]
    where = ["."]
    include = ["videotrans*"]
    # namespaces = false

    [project.scripts]
    pyvideotrans-cli = "videotrans.cli:main"
    pyvideotrans-gui = "videotrans.sp:main" # FIXME no main function
    EOF

    # fix: ModuleNotFoundError: No module named 'cli'
    mv cli.py sp.py videotrans

    substituteInPlace videotrans/cli.py videotrans/sp.py \
      --replace 'from videotrans.' 'from .'

    # fix: AttributeError: No huggingface_hub attribute configure_http_backend
    substituteInPlace videotrans/cli.py \
      --replace \
        'huggingface_hub.configure_http_backend(backend_factory=' \
        'huggingface_hub.set_client_factory(client_factory='

    # fix: OSError: [Errno 30] Read-only file system: '/nix/store/...'
    substituteInPlace videotrans/configure/config.py \
      --replace \
        'ROOT_DIR = ' \
        'ROOT_DIR = os.getcwd() # '

    # fix: many dependencies are not installed
    sed -i '/^dependencies = \[/,/^]/d' pyproject.toml

    # fix: ModuleNotFoundError: No module named 'alibabacloud_alimt20181012'
    # online processing modules should be optional
    sed -i -E 's/^from videotrans.translator.([^ ]+) import (.*)/try:\
        \0\
    except ModuleNotFoundError:\
        \2 = None/' videotrans/translator/__init__.py

    # fix: FileNotFoundError: [Errno 2] No such file or directory: 'videotrans/cfg.json'
    # FIXME cli.py should not write config files when only printing the helptext
    substituteInPlace videotrans/configure/config.py \
      --replace \
        "            with open(self._json_path, 'w', encoding='utf-8') as f:" \
        "$(
          echo "            os.makedirs(os.path.dirname(self._json_path), exist_ok=True)"
          echo "            with open(self._json_path, 'w', encoding='utf-8') as f:" \
        )"

    # fix: RuntimeError: The model download failed. "Unknown argument(s): {'name': 'huggingface_hub.snapshot_download'}"
    # https://github.com/LocalKinAI/ollamadiffuser/issues/1
    false &&
    substituteInPlace videotrans/util/help_down.py \
      --replace \
        'local_dir_use_symlinks=False' \
        '# local_dir_use_symlinks=False'

    substituteInPlace \
      videotrans/task/_speech2text.py \
      videotrans/util/help_down.py \
      videotrans/task/trans_create.py \
      --replace \
        'snapshot_download(' \
        'snapshot_download(tqdm_class=DummyTqdmClass,' \
      --replace 'tqdm_class=MyTqdmClass,' ""
    cat >videotrans/util/dummy_tqdm_class.py <<'EOF'
    import sys
    import time
    # class tqdm:
    class DummyTqdmClass:
        def __init__(self, iterable=None, total=None, desc="", width=40, **kwargs):
            print("DummyTqdmClass.__init__", dict(
                iterable=iterable,
                total=total,
                desc=desc,
                width=width,
                **kwargs,
            ))
            # DummyTqdmClass.__init__ {'iterable': None, 'total': 0, 'desc': 'Downloading (incomplete total...)', 'width': 40, 'disable': None, 'initial': 0, 'unit': 'B', 'unit_scale': True, 'name': 'huggingface_hub.snapshot_download'}
            self.iterable = iterable
            self.total = total if total is not None else len(iterable)
            self.desc = desc
            self.width = width
            self.n = 0
            self.start_time = time.time()

        def __iter__(self):
            for item in self.iterable:
                yield item
                self.n += 1
                self._print_progress()
            self._finish()

        def _print_progress(self):
            progress = self.n / self.total if self.total else 0
            filled = int(self.width * progress)
            bar = "#" * filled + "-" * (self.width - filled)

            elapsed = time.time() - self.start_time
            rate = self.n / elapsed if elapsed > 0 else 0

            msg = f"\r{self.desc} |{bar}| {self.n}/{self.total} [{rate:.2f} it/s]"
            sys.stdout.write(msg)
            sys.stdout.flush()

        def _finish(self):
            sys.stdout.write("\n")
            sys.stdout.flush()

        def get_lock(*a, **k):
            print("DummyTqdmClass.get_lock", a, k)

        def set_lock(*a, **k):
            print("DummyTqdmClass.set_lock", a, k)
    EOF
    sed -i '1 i\from .dummy_tqdm_class import DummyTqdmClass' videotrans/util/help_down.py
    sed -i '1 i\from ..util.dummy_tqdm_class import DummyTqdmClass' videotrans/task/_speech2text.py videotrans/task/trans_create.py
  '';

  build-system = [
    python.pkgs.setuptools
  ];

  dependencies = with python.pkgs; [
    absl-py
    accelerate
    addict
    aenum
    aiofiles
    aiohappyeyeballs
    aiohttp
    aiosignal
    /*
    alibabacloud-alimt20181012
    alibabacloud-credentials
    alibabacloud-endpoint-util
    alibabacloud-gateway-spi
    alibabacloud-openapi-util
    alibabacloud-openplatform20191219
    alibabacloud-oss-sdk
    alibabacloud-oss-util
    alibabacloud-tea
    alibabacloud-tea-fileform
    alibabacloud-tea-openapi
    alibabacloud-tea-util
    alibabacloud-tea-xml
    aliyun-python-sdk-core
    aliyun-python-sdk-kms
    */
    altgraph
    annotated-types
    anthropic
    # antlr4-python-runtime
    anyio
    asttokens
    astunparse
    async-timeout
    attrs
    audioread
    av
    # azure-cognitiveservices-speech
    blinker
    brotli
    cachetools
    # camb-sdk
    certifi
    cffi
    chardet
    charset-normalizer
    click
    colorama
    coloredlogs
    contourpy
    crcmod
    cryptography
    ctranslate2
    cycler
    dashscope
    dataclasses-json
    datasets
    decorator
    deepgram-captions
    deepgram-sdk
    deepl
    deprecation
    diffusers
    dill
    distro
    edge-tts
    editdistance
    elevenlabs
    exceptiongroup
    executing
    faster-whisper
    ffmpeg-python
    filelock
    flask
    flatbuffers
    fonttools
    frozenlist
    fsspec
    # funasr
    # future
    gast
    google-api-core
    google-api-python-client
    google-auth
    google-auth-httplib2
    google-auth-oauthlib
    google-cloud-texttospeech
    google-genai
    google-pasta
    googleapis-common-protos
    gradio-client
    grpcio
    grpcio-status
    gtts
    h11
    h2
    h5py
    # hdbscan # FIXME fix build
    hf-xet
    hpack
    hstspreload
    httpcore
    httplib2
    httpx
    # huggingface
    huggingface-hub
    humanfriendly
    hydra-core
    hyperframe
    idna
    imageio
    imageio-ffmpeg
    importlib-metadata
    inflate64
    ipython
    # iso639-lang
    itsdangerous
    jaconv
    jamo
    jedi
    jieba
    jinja2
    jiter
    jmespath
    joblib
    # kaldiio
    keras
    # keras-preprocessing
    kiwisolver
    lazy-loader
    libclang
    librosa
    llvmlite
    markdown
    markdown-it-py
    markupsafe
    marshmallow
    matplotlib-inline
    mdurl
    modelscope
    more-itertools
    mpmath
    msgpack
    multidict
    mypy-extensions
    networkx
    # norbert
    numba
    numpy
    oauthlib
    omegaconf
    onnxruntime
    openai
    openai-whisper
    opt-einsum
    ordered-set
    oss2
    packaging
    pandas
    parso
    pefile
    peft
    pillow
    pip
    # piper-tts
    platformdirs
    plyer
    pooch
    proglog
    prompt-toolkit
    propcache
    proto-plus
    protobuf
    psutil
    pure-eval
    py7zr
    # pyannote-audio # -> speechbrain -> python.13-hyperpyyaml-1.2.3 is broken
    pyarrow
    pyasn1
    pyasn1-modules
    pybcj
    pycparser
    pycryptodome
    pycryptodomex
    pydantic
    pydantic-core
    pydub
    pygments
    pyinstaller
    pyinstaller-hooks-contrib
    pynndescent
    pyparsing
    pyppmd
    # pyrubberband
    pyside6
    # pyside6-addons
    # pyside6-essentials
    pysoundfile
    python-dateutil
    # pytorch-wpe
    # pytsmod
    pytz
    pyyaml
    pyzstd
    qdarkstyle
    regex
    requests
    requests-oauthlib
    resampy
    rfc3986
    rich
    rsa
    safetensors
    scikit-learn
    scipy
    sentencepiece
    setuptools
    shellingham
    sherpa-onnx
    # sherpa-onnx-core
    shiboken6
    simplejson
    six
    snakeviz
    sniffio
    sortedcontainers
    sounddevice
    soundfile
    soxr
    # speechrecognition
    srt
    stack-data
    sympy
    tabulate
    ten-vad
    tenacity
    tencentcloud-sdk-python
    # tencentcloud-sdk-python-common
    # tencentcloud-sdk-python-tmt
    tensorboardx
    tiktoken
    torch
    # torch-complex
    # torchaudio # FIXME tests hang
    tqdm
    transformers
    typer
    typing-extensions
    typing-inspect
    tzdata
    urllib3
    websocket-client
    websockets
    wheel
    wrapt
    xxhash
    yarl
    zhconv
  ];

  /*
  optional-dependencies = with python.pkgs; {
    dotnet = [
      pythonnet
    ];
    qwen-asr = [
      qwen-asr
    ];
    qwen-tts = [
      qwen-tts
    ];
  };
  */

  pythonImportsCheck = [
#    "videotrans.util"
  ];

  meta = {
    description = "Translate the video from one language to another and embed dubbing & subtitles";
    homepage = "https://github.com/jianchang512/pyvideotrans";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "pyvideotrans";
  };
})
