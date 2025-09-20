{lib}:
lib.mkOption {
  type = lib.types.submodule {
    options = {
      providers = lib.mkOption {
        type = lib.types.attrsOf (
          lib.types.submodule {
            options = {
              id = lib.mkOption {
                type = lib.types.str;
                description = "Unique identifier for the provider";
              };
              name = lib.mkOption {
                type = lib.types.str;
                description = "Human-readable name for the provider";
              };
              base_url = lib.mkOption {
                type = lib.types.str;
                default = "";
                description = "Base URL for the provider's API";
              };
              type = lib.mkOption {
                type = lib.types.enum [
                  "openai"
                  "anthropic"
                  "gemini"
                  "azure"
                  "vertexai"
                ];
                default = "openai";
                description = "Provider type that determines the API format";
              };
              api_key = lib.mkOption {
                type = lib.types.str;
                default = "";
                description = "API key for authentication with the provider";
              };
              disable = lib.mkOption {
                type = lib.types.bool;
                default = false;
                description = "Whether this provider is disabled";
              };
              system_prompt_prefix = lib.mkOption {
                type = lib.types.str;
                default = "";
                description = "Custom prefix to add to system prompts for this provider";
              };
              extra_headers = lib.mkOption {
                type = lib.types.attrsOf lib.types.str;
                default = {};
                description = "Additional HTTP headers to send with requests";
              };
              extra_body = lib.mkOption {
                type = lib.types.attrsOf lib.types.anything;
                default = {};
                description = "Additional fields to include in request bodies";
              };
              models = lib.mkOption {
                type = lib.types.listOf (
                  lib.types.submodule {
                    options = {
                      id = lib.mkOption {
                        type = lib.types.str;
                        description = "Model ID";
                      };
                      name = lib.mkOption {
                        type = lib.types.str;
                        description = "Model display name";
                      };
                      cost_per_1m_in = lib.mkOption {
                        type = lib.types.number;
                        default = 0;
                        description = "Cost per 1M input tokens";
                      };
                      cost_per_1m_out = lib.mkOption {
                        type = lib.types.number;
                        default = 0;
                        description = "Cost per 1M output tokens";
                      };
                      cost_per_1m_in_cached = lib.mkOption {
                        type = lib.types.number;
                        default = 0;
                        description = "Cost per 1M cached input tokens";
                      };
                      cost_per_1m_out_cached = lib.mkOption {
                        type = lib.types.number;
                        default = 0;
                        description = "Cost per 1M cached output tokens";
                      };
                      context_window = lib.mkOption {
                        type = lib.types.int;
                        default = 128000;
                        description = "Maximum context window size";
                      };
                      default_max_tokens = lib.mkOption {
                        type = lib.types.int;
                        default = 8192;
                        description = "Default maximum tokens for responses";
                      };
                      can_reason = lib.mkOption {
                        type = lib.types.bool;
                        default = false;
                        description = "Whether the model supports reasoning";
                      };
                      has_reasoning_efforts = lib.mkOption {
                        type = lib.types.bool;
                        default = false;
                        description = "Whether the model supports reasoning effort levels";
                      };
                      default_reasoning_effort = lib.mkOption {
                        type = lib.types.str;
                        default = "";
                        description = "Default reasoning effort level";
                      };
                      supports_attachments = lib.mkOption {
                        type = lib.types.bool;
                        default = false;
                        description = "Whether the model supports file attachments";
                      };
                    };
                  }
                );
                default = [];
                description = "List of models available from this provider";
              };
            };
          }
        );
        default = {};
        description = "AI provider configurations";
      };

      lsp = lib.mkOption {
        type = lib.types.attrsOf (
          lib.types.submodule {
            options = {
              command = lib.mkOption {
                type = lib.types.str;
                description = "Command to execute for the LSP server";
              };
              args = lib.mkOption {
                type = lib.types.listOf lib.types.str;
                default = [];
                description = "Arguments to pass to the LSP server command";
              };
              options = lib.mkOption {
                type = lib.types.attrsOf lib.types.anything;
                default = {};
                description = "LSP server-specific configuration options";
              };
              enabled = lib.mkOption {
                type = lib.types.bool;
                default = false;
                description = "Whether this LSP server is enabled";
              };
            };
          }
        );
        default = {};
        description = "Language Server Protocol configurations";
      };

      mcp = lib.mkOption {
        type = lib.types.attrsOf (
          lib.types.submodule {
            options = {
              command = lib.mkOption {
                type = lib.types.str;
                default = "";
                description = "Command to execute for stdio MCP servers";
              };
              env = lib.mkOption {
                type = lib.types.attrsOf lib.types.str;
                default = {};
                description = "Environment variables to set for the MCP server";
              };
              args = lib.mkOption {
                type = lib.types.listOf lib.types.str;
                default = [];
                description = "Arguments to pass to the MCP server command";
              };
              type = lib.mkOption {
                type = lib.types.enum [
                  "stdio"
                  "sse"
                  "http"
                ];
                default = "stdio";
                description = "Type of MCP connection";
              };
              url = lib.mkOption {
                type = lib.types.str;
                default = "";
                description = "URL for HTTP or SSE MCP servers";
              };
              disabled = lib.mkOption {
                type = lib.types.bool;
                default = false;
                description = "Whether this MCP server is disabled";
              };
              headers = lib.mkOption {
                type = lib.types.attrsOf lib.types.str;
                default = {};
                description = "HTTP headers for HTTP/SSE MCP servers";
              };
            };
          }
        );
        default = {};
        description = "Model Context Protocol server configurations";
      };

      options = lib.mkOption {
        type = lib.types.submodule {
          options = {
            context_paths = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [];
              description = "Paths to files containing context information for the AI";
            };
            tui = lib.mkOption {
              type = lib.types.submodule {
                options = {
                  compact_mode = lib.mkOption {
                    type = lib.types.bool;
                    default = false;
                    description = "Enable compact mode for the TUI interface";
                  };
                };
              };
              default = {};
              description = "Terminal user interface options";
            };
            debug = lib.mkOption {
              type = lib.types.bool;
              default = false;
              description = "Enable debug logging";
            };
            debug_lsp = lib.mkOption {
              type = lib.types.bool;
              default = false;
              description = "Enable debug logging for LSP servers";
            };
            disable_auto_summarize = lib.mkOption {
              type = lib.types.bool;
              default = false;
              description = "Disable automatic conversation summarization";
            };
            data_directory = lib.mkOption {
              type = lib.types.str;
              default = ".crush";
              description = "Directory for storing application data (relative to working directory)";
            };
          };
        };
        default = {};
        description = "General application options";
      };

      permissions = lib.mkOption {
        type = lib.types.submodule {
          options = {
            allowed_tools = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [];
              description = "List of tools that don't require permission prompts";
            };
          };
        };
        default = {};
        description = "Permission settings for tool usage";
      };

      models = lib.mkOption {
        type = lib.types.attrsOf (
          lib.types.submodule {
            options = {
              model = lib.mkOption {
                type = lib.types.str;
                description = "The model ID as used by the provider API";
              };
              provider = lib.mkOption {
                type = lib.types.str;
                description = "The model provider ID that matches a key in the providers config";
              };
              reasoning_effort = lib.mkOption {
                type = lib.types.enum [
                  "low"
                  "medium"
                  "high"
                ];
                default = "";
                description = "Reasoning effort level for OpenAI models that support it";
              };
              max_tokens = lib.mkOption {
                type = lib.types.int;
                default = 0;
                description = "Maximum number of tokens for model responses";
              };
              think = lib.mkOption {
                type = lib.types.bool;
                default = false;
                description = "Enable thinking mode for Anthropic models that support reasoning";
              };
            };
          }
        );
        default = {};
        description = "Model configurations";
      };
    };
  };
  default = {};
}
