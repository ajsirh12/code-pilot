#!/usr/bin/env python3
"""
PII Scanner Hook (PostToolUse)

Scans written files for personally identifiable information.
Runs after Write/Edit operations.
"""

import sys
import json
import re
import os

# PII patterns to detect
PII_PATTERNS = [
    (r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b', 'Email address'),
    (r'\b\d{3}[-.]?\d{4}[-.]?\d{4}\b', 'Phone number (Korean)'),
    (r'\b\d{3}[-.]?\d{3,4}[-.]?\d{4}\b', 'Phone number'),
    (r'\b\d{6}[-]?\d{7}\b', 'Korean resident registration number'),
    (r'\b\d{3}-\d{2}-\d{5}\b', 'SSN pattern'),
    (r'\b(?:\d{4}[-\s]?){3}\d{4}\b', 'Credit card number'),
    (r'password\s*=\s*["\'][^"\']+["\']', 'Hardcoded password'),
    (r'api[_-]?key\s*=\s*["\'][^"\']+["\']', 'Hardcoded API key'),
    (r'secret\s*=\s*["\'][^"\']+["\']', 'Hardcoded secret'),
]

# File extensions to scan
SCANNABLE_EXTENSIONS = ['.js', '.ts', '.jsx', '.tsx', '.py', '.java', '.go', '.rs', '.json', '.yaml', '.yml', '.env']

# Paths to ignore
IGNORE_PATHS = ['node_modules', '.git', 'dist', 'build', '__pycache__', '.next']

def should_scan(file_path: str) -> bool:
    """Check if file should be scanned."""
    if not file_path:
        return False

    # Check ignored paths
    for ignore in IGNORE_PATHS:
        if ignore in file_path:
            return False

    # Check extension
    _, ext = os.path.splitext(file_path)
    return ext.lower() in SCANNABLE_EXTENSIONS

def scan_for_pii(content: str) -> list:
    """Scan content for PII."""
    findings = []

    for pattern, pii_type in PII_PATTERNS:
        matches = re.finditer(pattern, content, re.IGNORECASE)
        for match in matches:
            # Get line number
            line_num = content[:match.start()].count('\n') + 1
            # Mask the finding
            masked = match.group()[:3] + '***' + match.group()[-2:] if len(match.group()) > 5 else '***'
            findings.append(f"Line {line_num}: {pii_type} detected ({masked})")

    return findings

def main():
    tool_input = sys.stdin.read()

    try:
        data = json.loads(tool_input)
        file_path = data.get('file_path', '')
        content = data.get('content', '') or data.get('new_string', '')
    except json.JSONDecodeError:
        # Try to get file path from argument
        file_path = sys.argv[1] if len(sys.argv) > 1 else ''
        content = tool_input

    if not should_scan(file_path):
        sys.exit(0)

    # If we have a file path but no content, try to read the file
    if file_path and not content and os.path.exists(file_path):
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
        except:
            sys.exit(0)

    if not content:
        sys.exit(0)

    findings = scan_for_pii(content)

    if findings:
        print(f"🔍 PII Scanner found {len(findings)} potential issue(s):", file=sys.stderr)
        for finding in findings[:5]:  # Limit output
            print(f"  {finding}", file=sys.stderr)
        if len(findings) > 5:
            print(f"  ... and {len(findings) - 5} more", file=sys.stderr)
        print("\n💡 Remove or encrypt PII before committing.", file=sys.stderr)

    sys.exit(0)

if __name__ == '__main__':
    main()
