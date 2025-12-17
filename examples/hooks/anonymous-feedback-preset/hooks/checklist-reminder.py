#!/usr/bin/env python3
"""
Checklist Reminder Hook (Stop)

Reminds about anonymity and security checklist when Claude stops.
Runs at the end of each task.
"""

import sys

CHECKLIST = """
┌─────────────────────────────────────────────────────────────┐
│  📋 Anonymous Feedback Project Checklist                    │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Anonymity:                                                 │
│  □ User identifiers are hashed/anonymized                   │
│  □ No direct PII (email, name, IP) in logs                  │
│  □ Feedback cannot be traced back to user                   │
│  □ Admin cannot see who submitted what                      │
│                                                             │
│  Security:                                                  │
│  □ No hardcoded secrets or API keys                         │
│  □ Input validation on all user inputs                      │
│  □ SQL injection prevention (parameterized queries)         │
│  □ XSS prevention (output encoding)                         │
│                                                             │
│  Quality:                                                   │
│  □ TypeScript types are complete                            │
│  □ Error handling is in place                               │
│  □ Tests cover anonymity requirements                       │
│                                                             │
│  Documentation:                                             │
│  □ Privacy policy updated                                   │
│  □ Data retention policy documented                         │
│  □ API endpoints documented                                 │
│                                                             │
└─────────────────────────────────────────────────────────────┘
"""

def main():
    # Only show occasionally (you could add logic to track this)
    # For demo purposes, always show
    print(CHECKLIST, file=sys.stderr)
    sys.exit(0)

if __name__ == '__main__':
    main()
