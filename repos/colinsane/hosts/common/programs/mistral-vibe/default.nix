{ config, ... }:
{
  sane.programs.mistral-vibe = {
    sandbox.net = "all";
    sandbox.whitelistPwd = true;
    sandbox.extraHomePaths = [
      ".config/git"  #< for `git commit` to have my author name
      ".vibe"
    ];

    # unclear which of these are required
    fs.".vibe/config.toml".symlink.text = ''
      active_model = "local"
      vim_keybindings = false
      disable_welcome_banner_animation = true
      autocopy_to_clipboard = true
      file_watcher_for_autocomplete = false
      displayed_workdir = ""
      context_warnings = false
      voice_mode_enabled = false
      active_transcribe_model = "voxtral-realtime"
      auto_approve = false
      enable_telemetry = false
      system_prompt_id = "cli"
      include_commit_signature = false
      include_model_info = true
      include_project_context = true
      include_prompt_detail = true
      enable_update_checks = false
      enable_auto_update = false
      enable_notifications = true
      api_timeout = 720.0
      auto_compact_threshold = 200000
      tool_paths = []
      mcp_servers = []
      enabled_tools = []
      disabled_tools = []
      agent_paths = []
      enabled_agents = []
      disabled_agents = []
      installed_agents = []
      skill_paths = []
      enabled_skills = []
      disabled_skills = []

      [[providers]]
      name = "llamacpp"
      api_base = "http://${config.sane.hosts.by-name.desko.wg-home.ip}:11435/v1"
      api_key_env_var = ""
      api_style = "openai"
      backend = "generic"
      reasoning_field_name = "reasoning_content"
      project_id = ""
      region = ""

      [[models]]
      name = "devstral"
      provider = "llamacpp"
      alias = "local"
      temperature = 0.2
      input_price = 0.0
      output_price = 0.0
      thinking = "off"
      auto_compact_threshold = 200000

      [project_context]
      default_commit_count = 5
      timeout_seconds = 2.0

      [session_logging]
      save_dir = "/home/colin/.vibe/logs/session"
      session_prefix = "session"
      enabled = true

      [tools.ask_user_question]
      permission = "always"
      allowlist = []
      denylist = []

      [tools.bash]
      permission = "ask"
      allowlist = [
          "echo",
          "git diff",
          "git log",
          "git status",
          "tree",
          "whoami",
          "cat",
          "file",
          "head",
          "ls",
          "pwd",
          "stat",
          "tail",
          "uname",
          "wc",
          "which",
      ]
      denylist = [
          "gdb",
          "pdb",
          "passwd",
          "nano",
          "vim",
          "vi",
          "emacs",
          "bash -i",
          "sh -i",
          "zsh -i",
          "fish -i",
          "dash -i",
          "screen",
          "tmux",
      ]
      max_output_bytes = 16000
      default_timeout = 300
      denylist_standalone = [
          "python",
          "python3",
          "ipython",
          "bash",
          "sh",
          "nohup",
          "vi",
          "vim",
          "emacs",
          "nano",
          "su",
      ]

      [tools.exit_plan_mode]
      permission = "always"
      allowlist = []
      denylist = []

      [tools.grep]
      permission = "always"
      allowlist = []
      denylist = []
      max_output_bytes = 64000
      default_max_matches = 100
      default_timeout = 60
      exclude_patterns = [
          ".venv/",
          "venv/",
          ".env/",
          "env/",
          "node_modules/",
          ".git/",
          "__pycache__/",
          ".pytest_cache/",
          ".mypy_cache/",
          ".tox/",
          ".nox/",
          ".coverage/",
          "htmlcov/",
          "dist/",
          "build/",
          ".idea/",
          ".vscode/",
          "*.egg-info",
          "*.pyc",
          "*.pyo",
          "*.pyd",
          ".DS_Store",
          "Thumbs.db",
      ]
      codeignore_file = ".vibeignore"

      [tools.read_file]
      permission = "always"
      allowlist = []
      denylist = []
      max_read_bytes = 64000

      [tools.search_replace]
      permission = "ask"
      allowlist = []
      denylist = []
      max_content_size = 100000
      create_backup = false
      fuzzy_threshold = 0.9

      [tools.task]
      permission = "ask"
      allowlist = [
          "explore",
      ]
      denylist = []

      [tools.todo]
      permission = "always"
      allowlist = []
      denylist = []
      max_todos = 100

      [tools.web_fetch]
      permission = "ask"
      allowlist = []
      denylist = []
      default_timeout = 30
      max_timeout = 120
      max_content_bytes = 512000
      user_agent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"

      # [tools.web_search]
      # permission = "ask"
      # allowlist = []
      # denylist = []
      # timeout = 120
      # model = "mistral-vibe-cli-with-tools"

      [tools.write_file]
      permission = "ask"
      allowlist = []
      denylist = []
      max_write_bytes = 64000
      create_parent_dirs = true
    '';
  };
}
