# GitLab Plugin

GitLab MCP server for comprehensive GitLab API integration.

## Prerequisites

- Node.js v18+
- npm
- GitLab Personal Access Token with API scope

## Setup

Set your GitLab Personal Access Token as an environment variable:

```bash
# Linux/macOS
export GITLAB_PERSONAL_ACCESS_TOKEN="your-token-here"

# Windows (PowerShell)
$env:GITLAB_PERSONAL_ACCESS_TOKEN="your-token-here"

# Windows (CMD)
set GITLAB_PERSONAL_ACCESS_TOKEN=your-token-here
```

## Features

- Issue management (create, update, list, search)
- Merge Request workflows (create, review, merge)
- Pipeline management (trigger, view status, retry)
- Wiki page operations
- Milestone tracking
- Repository file operations

## Configuration

The plugin is pre-configured for TePS'EG GitLab instance:

| Setting | Value |
|---------|-------|
| API URL | `http://gitlab.tepseg.com:8087/api/v4` |
| Read Only Mode | `false` |
| Wiki Support | `true` |
| Milestone Support | `true` |
| Pipeline Support | `true` |

## Available Tools

The GitLab MCP server provides tools for:

| Category | Tools |
|----------|-------|
| Issues | `create_issue`, `update_issue`, `list_issues`, `get_issue` |
| Merge Requests | `create_mr`, `list_mrs`, `merge_mr`, `get_mr_diff` |
| Pipelines | `list_pipelines`, `get_pipeline`, `retry_pipeline`, `cancel_pipeline` |
| Wiki | `create_wiki_page`, `update_wiki_page`, `list_wiki_pages` |
| Milestones | `create_milestone`, `list_milestones`, `update_milestone` |
| Repository | `get_file`, `create_file`, `update_file`, `list_branches` |

## Usage Examples

Once the plugin is activated, Claude can:

1. **Manage Issues**
   - "Create an issue titled 'Fix login bug' in project mygroup/myproject"
   - "List all open issues assigned to me"

2. **Work with Merge Requests**
   - "Create a merge request from feature-branch to main"
   - "Show the diff for MR !123"

3. **Monitor Pipelines**
   - "Show the status of the latest pipeline"
   - "Retry the failed pipeline for commit abc123"

4. **Wiki Operations**
   - "Create a wiki page for the API documentation"
   - "List all wiki pages in the project"

## Resources

- [@zereight/mcp-gitlab on npm](https://www.npmjs.com/package/@zereight/mcp-gitlab)
- [GitLab API Documentation](https://docs.gitlab.com/ee/api/)
