{ lib
, buildPythonApplication
, aiohappyeyeballs
, fetchurl
, aiohttp
, aiosignal
, annotated-types
, anyio
, attrs
, backoff
, beautifulsoup4
, cachetools
, certifi
, cffi
, charset-normalizer
, click
, configargparse
, diff-match-patch
, diskcache
, distro
, filelock
, flake8
, frozenlist
, fsspec
, gitdb
, gitpython
, google-ai-generativelanguage
, google-api-core
, google-api-python-client
, google-auth
, google-auth-httplib2
, google-generativeai
, googleapis-common-protos
, grep-ast
, grpcio
, grpcio-status
, h11
, hf-xet
, httpcore
, httplib2
, httpx
, huggingface-hub
, idna
, importlib-metadata
, importlib-resources
, jinja2
, jiter
, json5
, jsonschema
, jsonschema-specifications
, litellm
, markdown-it-py
, markupsafe
, mccabe
, mdurl
, mixpanel
, mslex
, multidict
, networkx
, numpy
, openai
, oslex
, packaging
, pathspec
, pexpect
, pillow
, posthog
, prompt_toolkit
, propcache
, proto-plus
, protobuf
, psutil
, ptyprocess
, pyasn1
, pyasn1-modules
, pycodestyle
, pycparser
, pydantic
, pydantic-core
, pydub
, pyflakes
, pygments
, pypandoc
, pyparsing
, pyperclip
, python-dateutil
, python-dotenv
, pyyaml
, referencing
, regex
, requests
, rich
, rpds-py
, rsa
, scipy
, shtab
, six
, smmap
, sniffio
, socksio
, sounddevice
, soundfile
, soupsieve
, tiktoken
, tokenizers
, tqdm
, tree-sitter
, tree-sitter-c-sharp
, tree-sitter-embedded-template
, tree-sitter-language-pack
, tree-sitter-yaml
, typing-inspection
, typing-extensions
, uritemplate
, urllib3
, watchfiles
, wcwidth
, yarl
, zipp
,
}:
buildPythonApplication {
  pname = "aider-chat";
  version = "0.86.1";

  propagatedBuildInputs = [
    aiohappyeyeballs
    packaging
    aiohttp
    aiosignal
    annotated-types
    anyio
    attrs
    backoff
    beautifulsoup4
    cachetools
    certifi
    cffi
    charset-normalizer
    click
    configargparse
    diff-match-patch
    diskcache
    distro
    filelock
    flake8
    frozenlist
    fsspec
    gitdb
    gitpython
    google-ai-generativelanguage
    google-api-core
    google-api-python-client
    google-auth
    google-auth-httplib2
    google-generativeai
    googleapis-common-protos
    grep-ast
    grpcio
    grpcio-status
    h11
    hf-xet
    httpcore
    httplib2
    httpx
    huggingface-hub
    idna
    importlib-metadata
    importlib-resources
    jinja2
    jiter
    json5
    jsonschema
    jsonschema-specifications
    litellm
    markdown-it-py
    markupsafe
    mccabe
    mdurl
    mixpanel
    mslex
    multidict
    networkx
    numpy
    openai
    oslex
    packaging
    pathspec
    pexpect
    pillow
    posthog
    prompt_toolkit
    propcache
    proto-plus
    protobuf
    psutil
    ptyprocess
    pyasn1
    pyasn1-modules
    pycodestyle
    pycparser
    pydantic
    pydantic-core
    pydub
    pyflakes
    pygments
    pypandoc
    pyparsing
    pyperclip
    python-dateutil
    python-dotenv
    pyyaml
    referencing
    regex
    requests
    rich
    rpds-py
    rsa
    scipy
    shtab
    six
    smmap
    sniffio
    socksio
    sounddevice
    soundfile
    soupsieve
    tiktoken
    tokenizers
    tqdm
    tree-sitter
    tree-sitter-c-sharp
    tree-sitter-embedded-template
    tree-sitter-language-pack
    tree-sitter-yaml
    typing-inspection
    typing-extensions
    uritemplate
    urllib3
    watchfiles
    wcwidth
    yarl
    zipp
  ];

  format = "wheel";
  src = fetchurl {
    url = "https://files.pythonhosted.org/packages/a0/19/024e562ab9204dd30d1304e8cdfea8c998a0dc9fab72feb5c321fec804df/aider_chat-0.86.1-py3-none-any.whl";
    hash = "sha256-OvgoLEI4h/ReZa1QinsrZ7vtwnGnjvCY9cvoOa//Ttc=";
  };
  doCheck = false;
  dontBuild = true;

  meta = with lib; {
    description = "aider is AI pair programming in your terminal";
    mainProgram = "aider";
    homepage = "https://github.com/Aider-AI/aider";
    license = licenses.asl20;
  };
}
