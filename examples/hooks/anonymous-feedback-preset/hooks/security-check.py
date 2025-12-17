#!/usr/bin/env python3
"""
Security Check Hook (PreToolUse)

Checks bash commands for dangerous operations.
Runs before Bash tool execution.
"""

import sys
import json
import re

# Dangerous command patterns
BLOCKED_COMMANDS = [
    (r'rm\s+-rf\s+/', 'Recursive deletion of root'),
    (r'rm\s+-rf\s+~', 'Recursive deletion of home'),
    (r'>\s*/dev/sd', 'Writing to disk device'),
    (r'mkfs\.', 'Filesystem formatting'),
    (r'dd\s+if=.*of=/dev', 'Direct disk write'),
    (r'chmod\s+-R\s+777', 'Overly permissive chmod'),
    (r'curl.*\|\s*sh', 'Piping curl to shell'),
    (r'wget.*\|\s*sh', 'Piping wget to shell'),
]

# Patterns that might leak secrets
SECRET_PATTERNS = [
    (r'echo\s+.*\$\w*TOKEN', 'Echoing token to stdout'),
    (r'echo\s+.*\$\w*SECRET', 'Echoing secret to stdout'),
    (r'echo\s+.*\$\w*PASSWORD', 'Echoing password to stdout'),
    (r'echo\s+.*\$\w*API_KEY', 'Echoing API key to stdout'),
    (r'cat\s+.*\.env', 'Displaying .env file'),
    (r'printenv|env\s*$', 'Printing all environment variables'),
]

def check_command(command: str) -> list:
    """Check command for security issues."""
    issues = []

    for pattern, message in BLOCKED_COMMANDS:
        if re.search(pattern, command, re.IGNORECASE):
            issues.append(f"[BLOCKED] {message}")

    for pattern, message in SECRET_PATTERNS:
        if re.search(pattern, command, re.IGNORECASE):
            issues.append(f"[WARNING] {message}")

    return issues

def main():
    tool_input = sys.stdin.read()

    try:
        data = json.loads(tool_input)
        command = data.get('command', '')
    except json.JSONDecodeError:
        command = tool_input

    if not command:
        sys.exit(0)

    issues = check_command(command)

    blocked = [i for i in issues if i.startswith('[BLOCKED]')]
    warnings = [i for i in issues if i.startswith('[WARNING]')]

    if blocked:
        print("🚫 Security Check BLOCKED:", file=sys.stderr)
        for issue in blocked:
            print(f"  {issue}", file=sys.stderr)
        sys.exit(2)  # Block execution

    if warnings:
        print("⚠️  Security Check Warning:", file=sys.stderr)
        for issue in warnings:
            print(f"  {issue}", file=sys.stderr)

    sys.exit(0)

if __name__ == '__main__':
    main()
