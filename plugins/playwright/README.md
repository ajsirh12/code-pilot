# Playwright Plugin

Browser automation and end-to-end testing MCP server by Microsoft.

## Prerequisites

- Node.js v18+
- npm

## Features

- Web page interaction (click, type, scroll)
- Screenshot capture
- Form filling
- Element selection and manipulation
- Automated browser testing workflows

## Installation

This plugin uses Microsoft's official `@playwright/mcp` package, which is automatically installed via npx when the plugin is activated.

## Available Tools

The Playwright MCP server provides tools for:

| Tool | Description |
|------|-------------|
| `browser_navigate` | Navigate to a URL |
| `browser_screenshot` | Capture page screenshot |
| `browser_click` | Click an element |
| `browser_type` | Type text into an input |
| `browser_select` | Select option from dropdown |
| `browser_hover` | Hover over an element |
| `browser_evaluate` | Execute JavaScript |

## Usage Examples

Once the plugin is activated, Claude can:

1. **Navigate and screenshot**
   - "Go to https://example.com and take a screenshot"

2. **Fill forms**
   - "Fill out the login form with username 'test' and password 'demo'"

3. **Test workflows**
   - "Test the checkout flow on our e-commerce site"

4. **Debug UI issues**
   - "Click the submit button and show me what happens"

## Resources

- [Playwright MCP GitHub](https://github.com/microsoft/playwright-mcp)
- [Playwright Documentation](https://playwright.dev/)
