#!/usr/bin/env python3
"""Ralph Wiggum Stop Hook

Prevents session exit when a ralph-loop is active.
Feeds Claude's output back as input to continue the loop.
"""

import os
import sys
import json
import re


def parse_frontmatter(content):
    """Parse YAML frontmatter from markdown file."""
    lines = content.split('\n')
    if not lines or lines[0].strip() != '---':
        return {}, content

    frontmatter_lines = []
    body_start = 1
    for i, line in enumerate(lines[1:], 1):
        if line.strip() == '---':
            body_start = i + 1
            break
        frontmatter_lines.append(line)

    # Parse simple YAML key: value pairs
    frontmatter = {}
    for line in frontmatter_lines:
        if ':' in line:
            key, _, value = line.partition(':')
            key = key.strip()
            value = value.strip()
            # Remove surrounding quotes
            if value.startswith('"') and value.endswith('"'):
                value = value[1:-1]
            elif value.startswith("'") and value.endswith("'"):
                value = value[1:-1]
            frontmatter[key] = value

    body = '\n'.join(lines[body_start:])
    return frontmatter, body


def main():
    """Main entry point for Stop hook."""
    try:
        # Read hook input from stdin
        hook_input = json.load(sys.stdin)

        # Check if ralph-loop is active
        ralph_state_file = ".claude/ralph-loop.local.md"

        if not os.path.isfile(ralph_state_file):
            # No active loop - allow exit
            print(json.dumps({}))
            sys.exit(0)

        # Read and parse state file
        with open(ralph_state_file, 'r', encoding='utf-8') as f:
            content = f.read()

        frontmatter, prompt_text = parse_frontmatter(content)

        iteration_str = frontmatter.get('iteration', '')
        max_iterations_str = frontmatter.get('max_iterations', '')
        completion_promise = frontmatter.get('completion_promise', '')

        # Validate numeric fields
        if not iteration_str.isdigit():
            print(f"⚠️  Ralph loop: State file corrupted", file=sys.stderr)
            print(f"   File: {ralph_state_file}", file=sys.stderr)
            print(f"   Problem: 'iteration' field is not a valid number (got: '{iteration_str}')", file=sys.stderr)
            print("", file=sys.stderr)
            print("   This usually means the state file was manually edited or corrupted.", file=sys.stderr)
            print("   Ralph loop is stopping. Run /ralph-loop again to start fresh.", file=sys.stderr)
            os.remove(ralph_state_file)
            print(json.dumps({}))
            sys.exit(0)

        if not max_iterations_str.isdigit():
            print(f"⚠️  Ralph loop: State file corrupted", file=sys.stderr)
            print(f"   File: {ralph_state_file}", file=sys.stderr)
            print(f"   Problem: 'max_iterations' field is not a valid number (got: '{max_iterations_str}')", file=sys.stderr)
            print("", file=sys.stderr)
            print("   This usually means the state file was manually edited or corrupted.", file=sys.stderr)
            print("   Ralph loop is stopping. Run /ralph-loop again to start fresh.", file=sys.stderr)
            os.remove(ralph_state_file)
            print(json.dumps({}))
            sys.exit(0)

        iteration = int(iteration_str)
        max_iterations = int(max_iterations_str)

        # Check if max iterations reached
        if max_iterations > 0 and iteration >= max_iterations:
            print(f"🛑 Ralph loop: Max iterations ({max_iterations}) reached.")
            os.remove(ralph_state_file)
            print(json.dumps({}))
            sys.exit(0)

        # Get transcript path from hook input
        transcript_path = hook_input.get('transcript_path', '')

        if not transcript_path or not os.path.isfile(transcript_path):
            print("⚠️  Ralph loop: Transcript file not found", file=sys.stderr)
            print(f"   Expected: {transcript_path}", file=sys.stderr)
            print("   This is unusual and may indicate a Claude Code internal issue.", file=sys.stderr)
            print("   Ralph loop is stopping.", file=sys.stderr)
            os.remove(ralph_state_file)
            print(json.dumps({}))
            sys.exit(0)

        # Read transcript (JSONL format)
        with open(transcript_path, 'r', encoding='utf-8') as f:
            lines = f.readlines()

        # Find last assistant message
        last_assistant_line = None
        for line in reversed(lines):
            if '"role":"assistant"' in line or '"role": "assistant"' in line:
                last_assistant_line = line
                break

        if not last_assistant_line:
            print("⚠️  Ralph loop: No assistant messages found in transcript", file=sys.stderr)
            print(f"   Transcript: {transcript_path}", file=sys.stderr)
            print("   This is unusual and may indicate a transcript format issue", file=sys.stderr)
            print("   Ralph loop is stopping.", file=sys.stderr)
            os.remove(ralph_state_file)
            print(json.dumps({}))
            sys.exit(0)

        # Parse JSON
        try:
            msg_data = json.loads(last_assistant_line)
            content_blocks = msg_data.get('message', {}).get('content', [])
            text_parts = [block.get('text', '') for block in content_blocks if block.get('type') == 'text']
            last_output = '\n'.join(text_parts)
        except (json.JSONDecodeError, KeyError) as e:
            print("⚠️  Ralph loop: Failed to parse assistant message JSON", file=sys.stderr)
            print(f"   Error: {e}", file=sys.stderr)
            print("   This may indicate a transcript format issue", file=sys.stderr)
            print("   Ralph loop is stopping.", file=sys.stderr)
            os.remove(ralph_state_file)
            print(json.dumps({}))
            sys.exit(0)

        if not last_output:
            print("⚠️  Ralph loop: Assistant message contained no text content", file=sys.stderr)
            print("   Ralph loop is stopping.", file=sys.stderr)
            os.remove(ralph_state_file)
            print(json.dumps({}))
            sys.exit(0)

        # Check for completion promise
        if completion_promise and completion_promise != 'null':
            # Extract text from <promise> tags
            match = re.search(r'<promise>(.*?)</promise>', last_output, re.DOTALL)
            if match:
                promise_text = ' '.join(match.group(1).split())  # Normalize whitespace
                if promise_text == completion_promise:
                    print(f"✅ Ralph loop: Detected <promise>{completion_promise}</promise>")
                    os.remove(ralph_state_file)
                    print(json.dumps({}))
                    sys.exit(0)

        # Not complete - continue loop
        next_iteration = iteration + 1

        if not prompt_text.strip():
            print("⚠️  Ralph loop: State file corrupted or incomplete", file=sys.stderr)
            print(f"   File: {ralph_state_file}", file=sys.stderr)
            print("   Problem: No prompt text found", file=sys.stderr)
            print("", file=sys.stderr)
            print("   This usually means:", file=sys.stderr)
            print("     • State file was manually edited", file=sys.stderr)
            print("     • File was corrupted during writing", file=sys.stderr)
            print("", file=sys.stderr)
            print("   Ralph loop is stopping. Run /ralph-loop again to start fresh.", file=sys.stderr)
            os.remove(ralph_state_file)
            print(json.dumps({}))
            sys.exit(0)

        # Update iteration in state file
        new_content = content.replace(f'iteration: {iteration}', f'iteration: {next_iteration}')
        with open(ralph_state_file, 'w', encoding='utf-8') as f:
            f.write(new_content)

        # Build system message
        if completion_promise and completion_promise != 'null':
            system_msg = f"🔄 Ralph iteration {next_iteration} | To stop: output <promise>{completion_promise}</promise> (ONLY when statement is TRUE - do not lie to exit!)"
        else:
            system_msg = f"🔄 Ralph iteration {next_iteration} | No completion promise set - loop runs infinitely"

        # Output JSON to block the stop and feed prompt back
        result = {
            "decision": "block",
            "reason": prompt_text.strip(),
            "systemMessage": system_msg
        }
        print(json.dumps(result))

    except Exception as e:
        # On any error, allow the operation
        print(f"⚠️  Ralph loop error: {e}", file=sys.stderr)
        print(json.dumps({}))

    sys.exit(0)


if __name__ == '__main__':
    main()
