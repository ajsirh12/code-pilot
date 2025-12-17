#!/usr/bin/env bun

/**
 * Auto-close duplicate issues for GitLab
 *
 * This script finds issues that have been marked as duplicates (via bot comments)
 * and automatically closes them after a grace period if no one has objected.
 *
 * Environment Variables:
 *   GITLAB_TOKEN - GitLab personal access token with api scope (required)
 *   CI_API_V4_URL - GitLab API base URL (default: https://gitlab.com/api/v4)
 *   CI_PROJECT_ID - GitLab project ID (required)
 */

declare global {
  var process: {
    env: Record<string, string | undefined>;
  };
}

interface GitLabIssue {
  iid: number;
  title: string;
  author: { id: number };
  created_at: string;
  state: string;
  labels: string[];
}

interface GitLabNote {
  id: number;
  body: string;
  created_at: string;
  author: { id: number; username: string };
  system: boolean;
}

interface GitLabAwardEmoji {
  user: { id: number };
  name: string;
}

async function gitlabRequest<T>(
  baseUrl: string,
  endpoint: string,
  token: string,
  method: string = 'GET',
  body?: any
): Promise<T> {
  const response = await fetch(`${baseUrl}${endpoint}`, {
    method,
    headers: {
      'PRIVATE-TOKEN': token,
      'Content-Type': 'application/json',
    },
    ...(body && { body: JSON.stringify(body) }),
  });

  if (!response.ok) {
    const errorText = await response.text();
    throw new Error(
      `GitLab API request failed: ${response.status} ${response.statusText}\n${errorText}`
    );
  }

  // Handle empty responses (like 204 No Content)
  const text = await response.text();
  if (!text) return {} as T;

  return JSON.parse(text);
}

function extractDuplicateIssueNumber(noteBody: string): number | null {
  // Try to match #123 format first
  let match = noteBody.match(/#(\d+)/);
  if (match) {
    return parseInt(match[1], 10);
  }

  // Try to match GitLab issue URL format: https://gitlab.example.com/group/project/-/issues/123
  match = noteBody.match(/gitlab[^\/]*\/[^\/]+\/[^\/]+\/-\/issues\/(\d+)/);
  if (match) {
    return parseInt(match[1], 10);
  }

  return null;
}

async function closeIssueAsDuplicate(
  baseUrl: string,
  projectId: string,
  issueIid: number,
  duplicateOfIid: number,
  token: string
): Promise<void> {
  // Add duplicate label and close the issue
  await gitlabRequest(
    baseUrl,
    `/projects/${encodeURIComponent(projectId)}/issues/${issueIid}`,
    token,
    'PUT',
    {
      state_event: 'close',
      add_labels: 'duplicate'
    }
  );

  // Add closing comment
  await gitlabRequest(
    baseUrl,
    `/projects/${encodeURIComponent(projectId)}/issues/${issueIid}/notes`,
    token,
    'POST',
    {
      body: `This issue has been automatically closed as a duplicate of #${duplicateOfIid}.

If this is incorrect, please re-open this issue or create a new one.

🤖 Generated with [Code Pilot](https://gitlab.tepseg.com:8087/ai/code-pilot)`
    }
  );
}

async function autoCloseDuplicates(): Promise<void> {
  console.log("[DEBUG] Starting auto-close duplicates script (GitLab)");

  const token = process.env.GITLAB_TOKEN;
  if (!token) {
    throw new Error(`GITLAB_TOKEN environment variable is required

Usage:
  GITLAB_TOKEN=your_token CI_PROJECT_ID=123 bun run scripts/auto-close-duplicates.ts

Environment Variables:
  GITLAB_TOKEN   - GitLab personal access token with api scope (required)
  CI_API_V4_URL  - GitLab API base URL (default: https://gitlab.com/api/v4)
  CI_PROJECT_ID  - GitLab project ID (required)`);
  }
  console.log("[DEBUG] GitLab token found");

  const baseUrl = process.env.CI_API_V4_URL || 'https://gitlab.com/api/v4';
  const projectId = process.env.CI_PROJECT_ID;

  if (!projectId) {
    throw new Error("CI_PROJECT_ID environment variable is required");
  }

  console.log(`[DEBUG] GitLab API: ${baseUrl}`);
  console.log(`[DEBUG] Project ID: ${projectId}`);

  const threeDaysAgo = new Date();
  threeDaysAgo.setDate(threeDaysAgo.getDate() - 3);
  console.log(
    `[DEBUG] Checking for duplicate comments older than: ${threeDaysAgo.toISOString()}`
  );

  console.log("[DEBUG] Fetching open issues created more than 3 days ago...");
  const allIssues: GitLabIssue[] = [];
  let page = 1;
  const perPage = 100;

  while (true) {
    const pageIssues: GitLabIssue[] = await gitlabRequest(
      baseUrl,
      `/projects/${encodeURIComponent(projectId)}/issues?state=opened&per_page=${perPage}&page=${page}&order_by=created_at&sort=asc`,
      token
    );

    if (pageIssues.length === 0) break;

    // Filter for issues created more than 3 days ago
    const oldEnoughIssues = pageIssues.filter(issue =>
      new Date(issue.created_at) <= threeDaysAgo
    );

    allIssues.push(...oldEnoughIssues);
    page++;

    // Safety limit to avoid infinite loops
    if (page > 20) break;
  }

  const issues = allIssues;
  console.log(`[DEBUG] Found ${issues.length} open issues`);

  let processedCount = 0;
  let candidateCount = 0;

  for (const issue of issues) {
    processedCount++;
    console.log(
      `[DEBUG] Processing issue #${issue.iid} (${processedCount}/${issues.length}): ${issue.title}`
    );

    console.log(`[DEBUG] Fetching notes for issue #${issue.iid}...`);
    const notes: GitLabNote[] = await gitlabRequest(
      baseUrl,
      `/projects/${encodeURIComponent(projectId)}/issues/${issue.iid}/notes?per_page=100`,
      token
    );
    console.log(
      `[DEBUG] Issue #${issue.iid} has ${notes.length} notes`
    );

    // Look for duplicate detection comments (from bot or containing specific keywords)
    const dupeNotes = notes.filter(
      (note) =>
        !note.system &&
        note.body.includes("Found") &&
        note.body.includes("possible duplicate")
    );
    console.log(
      `[DEBUG] Issue #${issue.iid} has ${dupeNotes.length} duplicate detection notes`
    );

    if (dupeNotes.length === 0) {
      console.log(
        `[DEBUG] Issue #${issue.iid} - no duplicate notes found, skipping`
      );
      continue;
    }

    const lastDupeNote = dupeNotes[dupeNotes.length - 1];
    const dupeNoteDate = new Date(lastDupeNote.created_at);
    console.log(
      `[DEBUG] Issue #${issue.iid} - most recent duplicate note from: ${dupeNoteDate.toISOString()}`
    );

    if (dupeNoteDate > threeDaysAgo) {
      console.log(
        `[DEBUG] Issue #${issue.iid} - duplicate note is too recent, skipping`
      );
      continue;
    }
    console.log(
      `[DEBUG] Issue #${issue.iid} - duplicate note is old enough (${Math.floor(
        (Date.now() - dupeNoteDate.getTime()) / (1000 * 60 * 60 * 24)
      )} days)`
    );

    const notesAfterDupe = notes.filter(
      (note) => !note.system && new Date(note.created_at) > dupeNoteDate
    );
    console.log(
      `[DEBUG] Issue #${issue.iid} - ${notesAfterDupe.length} notes after duplicate detection`
    );

    if (notesAfterDupe.length > 0) {
      console.log(
        `[DEBUG] Issue #${issue.iid} - has activity after duplicate note, skipping`
      );
      continue;
    }

    console.log(
      `[DEBUG] Issue #${issue.iid} - checking award emojis on duplicate note...`
    );
    const awardEmojis: GitLabAwardEmoji[] = await gitlabRequest(
      baseUrl,
      `/projects/${encodeURIComponent(projectId)}/issues/${issue.iid}/notes/${lastDupeNote.id}/award_emoji`,
      token
    );
    console.log(
      `[DEBUG] Issue #${issue.iid} - duplicate note has ${awardEmojis.length} award emojis`
    );

    // Check for thumbsdown emoji from the issue author
    const authorThumbsDown = awardEmojis.some(
      (emoji) =>
        emoji.user.id === issue.author.id && emoji.name === 'thumbsdown'
    );
    console.log(
      `[DEBUG] Issue #${issue.iid} - author thumbs down reaction: ${authorThumbsDown}`
    );

    if (authorThumbsDown) {
      console.log(
        `[DEBUG] Issue #${issue.iid} - author disagreed with duplicate detection, skipping`
      );
      continue;
    }

    const duplicateIssueIid = extractDuplicateIssueNumber(lastDupeNote.body);
    if (!duplicateIssueIid) {
      console.log(
        `[DEBUG] Issue #${issue.iid} - could not extract duplicate issue number from note, skipping`
      );
      continue;
    }

    candidateCount++;

    try {
      console.log(
        `[INFO] Auto-closing issue #${issue.iid} as duplicate of #${duplicateIssueIid}`
      );
      await closeIssueAsDuplicate(baseUrl, projectId, issue.iid, duplicateIssueIid, token);
      console.log(
        `[SUCCESS] Successfully closed issue #${issue.iid} as duplicate of #${duplicateIssueIid}`
      );
    } catch (error) {
      console.error(
        `[ERROR] Failed to close issue #${issue.iid} as duplicate: ${error}`
      );
    }
  }

  console.log(
    `[DEBUG] Script completed. Processed ${processedCount} issues, found ${candidateCount} candidates for auto-close`
  );
}

autoCloseDuplicates().catch(console.error);

// Make it a module
export {};
