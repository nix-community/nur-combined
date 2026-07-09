---
name: save
description: "Session lifecycle management: persist session context and create recovery checkpoints"
category: session
complexity: standard
mcp-servers: []
personas: []
---

# /sc:save - Session Context Persistence

## Triggers
- Session completion and project context persistence needs
- Checkpoint creation requests
- Project understanding preservation and discovery archival scenarios
- Session lifecycle management and progress tracking requirements

## Usage
```
/sc:save [--type session|learnings|context|all] [--summarize] [--checkpoint]
```

## Behavioral Flow
1. **Analyze**: Examine session progress and identify discoveries worth preserving
2. **Persist**: Save session context and learnings to project memory
3. **Checkpoint**: Create recovery points for complex sessions and progress tracking
4. **Validate**: Ensure session data integrity
5. **Prepare**: Ready session context for seamless continuation in future sessions

Key behaviors:
- Session context preservation via project memory (`MEMORY.md` and per-fact files)
- Automatic checkpoint creation based on session progress and critical tasks
- Discovery and pattern archival
- Cross-session learning with accumulated project insights

## Tool Coordination
- **Write/Edit**: Persist session context to `MEMORY.md` and memory files
- **Read**: Retrieve prior session context
- **TodoRead**: Task completion tracking for automatic checkpoint triggers

## Key Patterns
- **Session Preservation**: Discovery analysis → memory file writes → checkpoint creation
- **Cross-Session Learning**: Context accumulation → pattern archival → enhanced project understanding
- **Progress Tracking**: Task completion → automatic checkpoints → session continuity
- **Recovery Planning**: State preservation → checkpoint validation → restoration readiness

## Examples

### Basic Session Save
```
/sc:save
# Saves current session discoveries and context to project memory
# Automatically creates checkpoint if session exceeds 30 minutes
```

### Comprehensive Session Checkpoint
```
/sc:save --type all --checkpoint
# Complete session preservation with recovery checkpoint
# Includes all learnings, context, and progress for session restoration
```

### Session Summary Generation
```
/sc:save --summarize
# Creates session summary with discovery documentation
# Updates cross-session learning patterns and project insights
```

### Discovery-Only Persistence
```
/sc:save --type learnings
# Saves only new patterns and insights discovered during session
# Updates project understanding without full session preservation
```

## Boundaries

**Will:**
- Save session context to project memory for cross-session persistence
- Create automatic checkpoints based on session progress and task completion
- Preserve discoveries and patterns for enhanced project understanding

**Will Not:**
- Save session data without validation and integrity verification
- Override existing session context without proper checkpoint preservation