---
name: load
description: "Session lifecycle management: activate the project (Serena) and load project context"
category: session
complexity: standard
mcp-servers: [serena]
personas: []
---

# /sc:load - Project Context Loading

## Triggers
- Session initialization and project context loading requests
- Project activation and context management requirements
- Session lifecycle management and checkpoint loading scenarios

## Usage
```
/sc:load [target] [--type project|config|deps|checkpoint] [--refresh] [--analyze]
```

## Behavioral Flow
1. **Initialize**: Activate the project via Serena
2. **Discover**: Analyze project structure and identify context loading requirements
3. **Load**: Retrieve project context and checkpoints
4. **Activate**: Establish project context and prepare for development workflow
5. **Validate**: Ensure loaded context integrity and session readiness

Key behaviors:
- Serena for project/symbol activation
- Project activation with comprehensive context loading and validation
- Performance-critical operation with <500ms initialization target
- Session lifecycle management with checkpoint coordination

## MCP Integration
- **Serena MCP**: Project activation and symbol-level code navigation (`activate_project`)
- **Performance Critical**: <200ms for core operations, <1s for checkpoint creation

## Tool Coordination
- **activate_project** (Serena): Core project activation and code-navigation context
- **Read/Grep/Glob**: Project structure analysis and configuration discovery

## Key Patterns
- **Project Activation**: Directory analysis → memory retrieval → context establishment
- **Session Restoration**: Checkpoint loading → context validation → workflow preparation
- **Memory Management**: Cross-session persistence → context continuity → development efficiency
- **Performance Critical**: Fast initialization → immediate productivity → session readiness

## Examples

### Basic Project Loading
```
/sc:load
# Activates the project via Serena and loads session memory
# Establishes session context and prepares for development workflow
```

### Specific Project Loading
```
/sc:load /path/to/project --type project --analyze
# Loads specific project with comprehensive analysis
# Activates project context and retrieves cross-session memories
```

### Checkpoint Restoration
```
/sc:load --type checkpoint --checkpoint session_123
# Restores specific checkpoint with session context
# Continues previous work session with full context preservation
```

### Dependency Context Loading
```
/sc:load --type deps --refresh
# Loads dependency context with fresh analysis
# Updates project understanding and dependency mapping
```

## Boundaries

**Will:**
- Activate the project via Serena and load session memory
- Provide session lifecycle management
- Establish project activation with comprehensive context loading

**Will Not:**
- Modify project structure or configuration without explicit permission
- Load context without proper Serena (activation) integration
- Override existing session context without checkpoint preservation