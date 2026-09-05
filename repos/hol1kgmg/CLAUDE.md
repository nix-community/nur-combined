# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Visual braille Unicode search tool with 256-character pattern matching, built with Next.js and TypeScript.

## Rules and Skills Structure

- **Rules** (`.claude/rules/`): Automatically loaded based on file paths. Source of truth for project conventions.
- **Skills** (`.claude/skills/`): Manually invoked for specific integrations.

## Available Rules

| Rule                    | Applies To | Description                                    |
| ----------------------- | ---------- | ---------------------------------------------- |
| **typescript-patterns** | `**/*.ts`  | TypeScript coding patterns and conventions     |

_Note: Rules will be added as the project evolves._

## Available Skills

| Skill                | When to Use                                    |
| -------------------- | ---------------------------------------------- |
| **frontend-design**  | Building web components, pages, or applications with distinctive, production-grade design |

## Work Rules

1. Propose implementation plan
2. Wait for approval
3. Start implementation

## Tool Usage Policy

**Always use dedicated tools for file operations:**

- File reading → `Read` tool
- File search → `Glob` tool
- Content search → `Grep` tool
- File editing → `Edit` tool
- File writing → `Write` tool

## Language Settings

- Responses: Japanese
- Thinking: English (for token reduction)