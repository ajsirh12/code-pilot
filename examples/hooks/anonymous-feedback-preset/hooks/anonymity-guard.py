#!/usr/bin/env python3
"""
Anonymity Guard Hook (PreToolUse)

Checks code for patterns that could compromise user anonymity.
Runs before Write/Edit operations.
"""

import sys
import json
import re

# Patterns that could compromise anonymity
DANGEROUS_PATTERNS = [
    (r'user\.email', 'Direct email access - use anonymous identifier instead'),
    (r'user\.name', 'Direct name access - use anonymous identifier instead'),
    (r'user\.id(?!\s*=\s*uuid)', 'User ID exposed - ensure it is anonymized'),
    (r'req\.ip|request\.ip|client\.ip', 'IP address logging - this breaks anonymity'),
    (r'getUser\(\)|getCurrentUser\(\)', 'User fetch without anonymization'),
    (r'localStorage\.setItem.*user', 'Storing user data in localStorage'),
    (r'console\.log.*user', 'Logging user data to console'),
    (r'tracking|analytics.*user', 'User tracking detected'),
]

# Patterns that are encouraged for anonymity
GOOD_PATTERNS = [
    r'anonymousId',
    r'hashedUserId',
    r'uuid\.v4',
    r'crypto\.randomUUID',
]

def check_anonymity(content: str) -> list:
    """Check content for anonymity violations."""
    issues = []

    for pattern, message in DANGEROUS_PATTERNS:
        matches = re.finditer(pattern, content, re.IGNORECASE)
        for match in matches:
            # Check if it's in a comment
            line_start = content.rfind('\n', 0, match.start()) + 1
            line = content[line_start:match.end()]
            if '//' in line[:line.find(match.group())] or line.strip().startswith('#'):
                continue
            issues.append(f"[ANONYMITY] {message}: '{match.group()}'")

    return issues

def main():
    # Read tool input from stdin
    tool_input = sys.stdin.read()

    try:
        data = json.loads(tool_input)
        content = data.get('content', '') or data.get('new_string', '')
    except json.JSONDecodeError:
        content = tool_input

    if not content:
        sys.exit(0)

    issues = check_anonymity(content)

    if issues:
        print("⚠️  Anonymity Guard Warning:", file=sys.stderr)
        for issue in issues:
            print(f"  {issue}", file=sys.stderr)
        print("\n💡 Consider using anonymousId or hashedUserId instead.", file=sys.stderr)
        # Exit 0 to allow (warning only), exit 1 to block
        sys.exit(0)

    sys.exit(0)

if __name__ == '__main__':
    main()
