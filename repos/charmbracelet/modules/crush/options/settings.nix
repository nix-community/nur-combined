{ lib }:

lib.mkOption {
  type = lib.types.submodule {
    options = {
      lsp = lib.mkOption {
        type = lib.types.attrsOf (
          lib.types.submodule {
            options = {
              args = lib.mkOption {
                type = lib.types.nullOr (lib.types.listOf lib.types.str);
                default = null;
                description = "Arguments to pass to the LSP server command";
              };

              command = lib.mkOption {
                type = lib.types.nullOr lib.types.str;
                default = null;
                description = "Command to execute for the LSP server";
              };

              disabled = lib.mkOption {
                type = lib.types.nullOr lib.types.bool;
                default = false;
                description = "Whether this LSP server is disabled";
              };

              env = lib.mkOption {
                type = lib.types.nullOr lib.types.attrsOf lib.types.anything;
                default = null;
                description = "Environment variables to set to the LSP server command";
              };

              filetypes = lib.mkOption {
                type = lib.types.nullOr (lib.types.listOf lib.types.str);
                default = null;
                description = "File types this LSP server handles";
              };

              init_options = lib.mkOption {
                type = lib.types.nullOr (lib.types.attrsOf lib.types.anything);
                default = null;
                description = "Initialization options passed to the LSP server during initialize request";
              };

              options = lib.mkOption {
                type = lib.types.nullOr (lib.types.attrsOf lib.types.anything);
                default = null;
                description = "LSP server-specific settings passed during initialization";
              };

              root_markers = lib.mkOption {
                type = lib.types.nullOr (lib.types.listOf lib.types.str);
                default = null;
                description = "Files or directories that indicate the project root";
              };

            };
          }
        );
        default = { };
        description = "Language Server Protocol configurations";
      };

      mcp = lib.mkOption {
        type = lib.types.attrsOf (
          lib.types.submodule {
            options = {
              args = lib.mkOption {
                type = lib.types.nullOr (lib.types.listOf lib.types.str);
                default = null;
                description = "Arguments to pass to the MCP server command";
              };

              command = lib.mkOption {
                type = lib.types.nullOr lib.types.str;
                default = null;
                description = "Command to execute for stdio MCP servers";
              };

              disabled = lib.mkOption {
                type = lib.types.nullOr lib.types.bool;
                default = false;
                description = "Whether this MCP server is disabled";
              };

              disabled_tools = lib.mkOption {
                type = lib.types.nullOr (lib.types.listOf lib.types.str);
                default = null;
                description = "List of tools from this MCP server to disable";
              };

              env = lib.mkOption {
                type = lib.types.nullOr lib.types.attrsOf lib.types.anything;
                default = null;
                description = "Environment variables to set for the MCP server";
              };

              headers = lib.mkOption {
                type = lib.types.nullOr lib.types.attrsOf lib.types.anything;
                default = null;
                description = "HTTP headers for HTTP/SSE MCP servers";
              };

              timeout = lib.mkOption {
                type = lib.types.nullOr lib.types.int;
                default = 15;
                description = "Timeout in seconds for MCP server connections";
              };

              type = lib.mkOption {
                type = lib.types.nullOr (
                  lib.types.enum [
                    "stdio"
                    "sse"
                    "http"
                  ]
                );
                default = "stdio";
                description = "Type of MCP connection";
              };

              url = lib.mkOption {
                type = lib.types.nullOr lib.types.str;
                default = null;
                description = "URL for HTTP or SSE MCP servers";
              };

            };
          }
        );
        default = { };
        description = "Model Context Protocol server configurations";
      };

      models = lib.mkOption {
        type = lib.types.attrsOf (
          lib.types.submodule {
            options = {
              frequency_penalty = lib.mkOption {
                type = lib.types.nullOr lib.types.number;
                default = null;
                description = "Frequency penalty to reduce repetition";
              };

              max_tokens = lib.mkOption {
                type = lib.types.nullOr lib.types.int;
                default = null;
                description = "Maximum number of tokens for model responses";
              };

              model = lib.mkOption {
                type = lib.types.nullOr lib.types.str;
                default = null;
                description = "The model ID as used by the provider API";
              };

              presence_penalty = lib.mkOption {
                type = lib.types.nullOr lib.types.number;
                default = null;
                description = "Presence penalty to increase topic diversity";
              };

              provider = lib.mkOption {
                type = lib.types.nullOr lib.types.str;
                default = null;
                description = "The model provider ID that matches a key in the providers config";
              };

              provider_options = lib.mkOption {
                type = lib.types.nullOr (lib.types.attrsOf lib.types.anything);
                default = null;
                description = "Additional provider-specific options for the model";
              };

              reasoning_effort = lib.mkOption {
                type = lib.types.nullOr (
                  lib.types.enum [
                    "low"
                    "medium"
                    "high"
                  ]
                );
                default = null;
                description = "Reasoning effort level for OpenAI models that support it";
              };

              temperature = lib.mkOption {
                type = lib.types.nullOr lib.types.number;
                default = null;
                description = "Sampling temperature";
              };

              think = lib.mkOption {
                type = lib.types.nullOr lib.types.bool;
                default = null;
                description = "Enable thinking mode for Anthropic models that support reasoning";
              };

              top_k = lib.mkOption {
                type = lib.types.nullOr lib.types.int;
                default = null;
                description = "Top-k sampling parameter";
              };

              top_p = lib.mkOption {
                type = lib.types.nullOr lib.types.number;
                default = null;
                description = "Top-p (nucleus) sampling parameter";
              };

            };
          }
        );
        default = { };
        description = "Model configurations for different model types";
      };

      options = lib.mkOption {
        type = lib.types.submodule {
          options = {
            attribution = lib.mkOption {
              type = lib.types.submodule {
                options = {
                  co_authored_by = lib.mkOption {
                    type = lib.types.nullOr lib.types.bool;
                    default = null;
                    description = "Deprecated: use trailer_style instead";
                  };

                  generated_with = lib.mkOption {
                    type = lib.types.nullOr lib.types.bool;
                    default = true;
                    description = "Add Generated with Crush line to commit messages and issues and PRs";
                  };

                  trailer_style = lib.mkOption {
                    type = lib.types.nullOr (
                      lib.types.enum [
                        "none"
                        "co-authored-by"
                        "assisted-by"
                      ]
                    );
                    default = "assisted-by";
                    description = "Style of attribution trailer to add to commits";
                  };

                };
              };
              default = { };
              description = "Attribution settings for generated content";
            };

            context_paths = lib.mkOption {
              type = lib.types.nullOr (lib.types.listOf lib.types.str);
              default = null;
              description = "Paths to files containing context information for the AI";
            };

            data_directory = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = ".crush";
              description = "Directory for storing application data (relative to working directory)";
            };

            debug = lib.mkOption {
              type = lib.types.nullOr lib.types.bool;
              default = false;
              description = "Enable debug logging";
            };

            debug_lsp = lib.mkOption {
              type = lib.types.nullOr lib.types.bool;
              default = false;
              description = "Enable debug logging for LSP servers";
            };

            disable_auto_summarize = lib.mkOption {
              type = lib.types.nullOr lib.types.bool;
              default = false;
              description = "Disable automatic conversation summarization";
            };

            disable_default_providers = lib.mkOption {
              type = lib.types.nullOr lib.types.bool;
              default = false;
              description = "Ignore all default/embedded providers. When enabled";
            };

            disable_metrics = lib.mkOption {
              type = lib.types.nullOr lib.types.bool;
              default = false;
              description = "Disable sending metrics";
            };

            disable_provider_auto_update = lib.mkOption {
              type = lib.types.nullOr lib.types.bool;
              default = false;
              description = "Disable providers auto-update";
            };

            disabled_tools = lib.mkOption {
              type = lib.types.nullOr (lib.types.listOf lib.types.str);
              default = null;
              description = "List of built-in tools to disable and hide from the agent";
            };

            initialize_as = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = "AGENTS.md";
              description = "Name of the context file to create/update during project initialization";
            };

            skills_paths = lib.mkOption {
              type = lib.types.nullOr (lib.types.listOf lib.types.str);
              default = null;
              description = "Paths to directories containing Agent Skills (folders with SKILL.md files)";
            };

            tui = lib.mkOption {
              type = lib.types.submodule {
                options = {
                  compact_mode = lib.mkOption {
                    type = lib.types.nullOr lib.types.bool;
                    default = false;
                    description = "Enable compact mode for the TUI interface";
                  };

                  completions = lib.mkOption {
                    type = lib.types.submodule {
                      options = {
                        max_depth = lib.mkOption {
                          type = lib.types.nullOr lib.types.int;
                          default = 0;
                          description = "Maximum depth for the ls tool";
                        };

                        max_items = lib.mkOption {
                          type = lib.types.nullOr lib.types.int;
                          default = 1000;
                          description = "Maximum number of items to return for the ls tool";
                        };

                      };
                    };
                    default = { };
                    description = "Completions UI options";
                  };

                  diff_mode = lib.mkOption {
                    type = lib.types.nullOr (
                      lib.types.enum [
                        "unified"
                        "split"
                      ]
                    );
                    default = null;
                    description = "Diff mode for the TUI interface";
                  };

                };
              };
              default = { };
              description = "Terminal user interface options";
            };

          };
        };
        default = { };
        description = "General application options";
      };

      permissions = lib.mkOption {
        type = lib.types.submodule {
          options = {
            allowed_tools = lib.mkOption {
              type = lib.types.nullOr (lib.types.listOf lib.types.str);
              default = null;
              description = "List of tools that don't require permission prompts";
            };

          };
        };
        default = { };
        description = "Permission settings for tool usage";
      };

      providers = lib.mkOption {
        type = lib.types.attrsOf (
          lib.types.submodule {
            options = {
              api_key = lib.mkOption {
                type = lib.types.nullOr lib.types.str;
                default = null;
                description = "API key for authentication with the provider";
              };

              base_url = lib.mkOption {
                type = lib.types.nullOr lib.types.str;
                default = null;
                description = "Base URL for the provider's API";
              };

              disable = lib.mkOption {
                type = lib.types.nullOr lib.types.bool;
                default = false;
                description = "Whether this provider is disabled";
              };

              extra_body = lib.mkOption {
                type = lib.types.nullOr (lib.types.attrsOf lib.types.anything);
                default = null;
                description = "Additional fields to include in request bodies";
              };

              extra_headers = lib.mkOption {
                type = lib.types.nullOr lib.types.attrsOf lib.types.anything;
                default = null;
                description = "Additional HTTP headers to send with requests";
              };

              id = lib.mkOption {
                type = lib.types.nullOr lib.types.str;
                default = null;
                description = "Unique identifier for the provider";
              };

              models = lib.mkOption {
                type = lib.types.listOf (
                  lib.types.submodule {
                    options = {
                      can_reason = lib.mkOption {
                        type = lib.types.nullOr lib.types.bool;
                        default = null;
                        description = "Can reason";
                      };

                      context_window = lib.mkOption {
                        type = lib.types.nullOr lib.types.int;
                        default = null;
                        description = "Context window";
                      };

                      cost_per_1m_in = lib.mkOption {
                        type = lib.types.nullOr lib.types.number;
                        default = null;
                        description = "Cost per 1m in";
                      };

                      cost_per_1m_in_cached = lib.mkOption {
                        type = lib.types.nullOr lib.types.number;
                        default = null;
                        description = "Cost per 1m in cached";
                      };

                      cost_per_1m_out = lib.mkOption {
                        type = lib.types.nullOr lib.types.number;
                        default = null;
                        description = "Cost per 1m out";
                      };

                      cost_per_1m_out_cached = lib.mkOption {
                        type = lib.types.nullOr lib.types.number;
                        default = null;
                        description = "Cost per 1m out cached";
                      };

                      default_max_tokens = lib.mkOption {
                        type = lib.types.nullOr lib.types.int;
                        default = null;
                        description = "Default max tokens";
                      };

                      default_reasoning_effort = lib.mkOption {
                        type = lib.types.nullOr lib.types.str;
                        default = null;
                        description = "Default reasoning effort";
                      };

                      id = lib.mkOption {
                        type = lib.types.nullOr lib.types.str;
                        default = null;
                        description = "Id";
                      };

                      name = lib.mkOption {
                        type = lib.types.nullOr lib.types.str;
                        default = null;
                        description = "Name";
                      };

                      options = lib.mkOption {
                        type = lib.types.submodule {
                          options = {
                            frequency_penalty = lib.mkOption {
                              type = lib.types.nullOr lib.types.number;
                              default = null;
                              description = "Frequency penalty";
                            };

                            presence_penalty = lib.mkOption {
                              type = lib.types.nullOr lib.types.number;
                              default = null;
                              description = "Presence penalty";
                            };

                            provider_options = lib.mkOption {
                              type = lib.types.nullOr (lib.types.attrsOf lib.types.anything);
                              default = null;
                              description = "Provider options";
                            };

                            temperature = lib.mkOption {
                              type = lib.types.nullOr lib.types.number;
                              default = null;
                              description = "Temperature";
                            };

                            top_k = lib.mkOption {
                              type = lib.types.nullOr lib.types.int;
                              default = null;
                              description = "Top k";
                            };

                            top_p = lib.mkOption {
                              type = lib.types.nullOr lib.types.number;
                              default = null;
                              description = "Top p";
                            };

                          };
                        };
                        default = { };
                        description = "Options";
                      };

                      reasoning_levels = lib.mkOption {
                        type = lib.types.nullOr (lib.types.listOf lib.types.str);
                        default = null;
                        description = "Reasoning levels";
                      };

                      supports_attachments = lib.mkOption {
                        type = lib.types.nullOr lib.types.bool;
                        default = null;
                        description = "Supports attachments";
                      };

                    };
                  }
                );
                default = { };
                description = "List of models available from this provider";
              };

              name = lib.mkOption {
                type = lib.types.nullOr lib.types.str;
                default = null;
                description = "Human-readable name for the provider";
              };

              oauth = lib.mkOption {
                type = lib.types.submodule {
                  options = {
                    access_token = lib.mkOption {
                      type = lib.types.nullOr lib.types.str;
                      default = null;
                      description = "Access token";
                    };

                    expires_at = lib.mkOption {
                      type = lib.types.nullOr lib.types.int;
                      default = null;
                      description = "Expires at";
                    };

                    expires_in = lib.mkOption {
                      type = lib.types.nullOr lib.types.int;
                      default = null;
                      description = "Expires in";
                    };

                    refresh_token = lib.mkOption {
                      type = lib.types.nullOr lib.types.str;
                      default = null;
                      description = "Refresh token";
                    };

                  };
                };
                default = { };
                description = "OAuth2 token for authentication with the provider";
              };

              provider_options = lib.mkOption {
                type = lib.types.nullOr (lib.types.attrsOf lib.types.anything);
                default = null;
                description = "Additional provider-specific options for this provider";
              };

              system_prompt_prefix = lib.mkOption {
                type = lib.types.nullOr lib.types.str;
                default = null;
                description = "Custom prefix to add to system prompts for this provider";
              };

              type = lib.mkOption {
                type = lib.types.nullOr (
                  lib.types.enum [
                    "openai"
                    "openai-compat"
                    "anthropic"
                    "gemini"
                    "azure"
                    "vertexai"
                  ]
                );
                default = "openai";
                description = "Provider type that determines the API format";
              };

            };
          }
        );
        default = { };
        description = "AI provider configurations";
      };

      tools = lib.mkOption {
        type = lib.types.submodule {
          options = {
            ls = lib.mkOption {
              type = lib.types.submodule {
                options = {
                  max_depth = lib.mkOption {
                    type = lib.types.nullOr lib.types.int;
                    default = 0;
                    description = "Maximum depth for the ls tool";
                  };

                  max_items = lib.mkOption {
                    type = lib.types.nullOr lib.types.int;
                    default = 1000;
                    description = "Maximum number of items to return for the ls tool";
                  };

                };
              };
              default = { };
              description = "Ls";
            };

          };
        };
        default = { };
        description = "Tool configurations";
      };

    };
  };
  default = { };
}
