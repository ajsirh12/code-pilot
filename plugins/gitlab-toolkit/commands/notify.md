---
description: Manage GitLab notification settings
argument-hint: "settings | mute #id | watch #id | global"
allowed-tools: Bash(curl:*), AskUserQuestion, TodoWrite
---

# GitLab Notification Settings

You are helping a developer manage their GitLab notification preferences.

## Core Principles

- **Reduce noise**: Mute what's not relevant
- **Stay informed**: Watch what matters
- **Per-item control**: Fine-grained settings

---

## Action Detection

Parse the user's request from: $ARGUMENTS

**Supported actions**:
- `settings` - View/edit notification settings
- `mute #id` or `mute !id` - Mute specific issue/MR
- `watch #id` or `watch !id` - Watch specific issue/MR
- `global` - Global notification settings
- `project` - Project notification settings
- (empty) - Show current settings

---

## Workflow: View Settings

**Phase 1: Get Notification Settings**

```bash
# Get project notification settings
curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/notification_settings" | \
  jq '{level, events}'

# Get global notification settings
curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/notification_settings" | \
  jq '{level, notification_email}'
```

**Phase 2: Present Settings**

```
🔔 Notification Settings

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📧 GLOBAL SETTINGS

Level: Participating
Email: john@example.com

You receive notifications when:
✅ Mentioned (@john)
✅ Assigned to you
✅ Your MRs updated
❌ All project activity

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📁 PROJECT: my-project

Level: Watch (all activity)

Events:
✅ New issues
✅ New MRs
✅ Pipeline failures
✅ Comments
❌ Push events

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔕 MUTED ITEMS (3)

#123  Login bug            muted 2d ago
!45   OAuth feature        muted 1w ago
#89   Old feature request  muted 1m ago

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Actions:
1. Change project level
2. Change global level
3. Unmute item
4. Mute new item

What would you like to do?
```

---

## Workflow: Change Notification Level

**Phase 1: Show Options**

```
🔔 Notification Level for: my-project

Current: Watch (all activity)

Available levels:
1. Disabled - No notifications at all
2. Participating - Only when mentioned or participating
3. Watch - All activity (current)
4. Global - Use global setting (Participating)
5. Custom - Choose specific events

Which level?
```

**Phase 2: For Custom Level**

```
🔔 Custom Notifications for: my-project

Choose events to receive notifications for:

Issue Events:
[ ] New issue
[x] Issue assigned to me
[ ] Issue closed
[x] Issue comment

MR Events:
[x] New MR
[x] MR assigned to me
[x] MR merged
[x] MR comment
[ ] MR approved

Pipeline Events:
[x] Pipeline failed
[ ] Pipeline succeeded
[ ] Pipeline fixed

Other:
[ ] Push events
[ ] Wiki changes

Apply these settings?
```

**Phase 3: Apply Settings**

```bash
curl --request PUT \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{
    "level": "custom",
    "new_issue": false,
    "new_merge_request": true,
    "merge_merge_request": true,
    "failed_pipeline": true,
    "success_pipeline": false
  }' \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/notification_settings"
```

**Phase 4: Report Result**

```
✅ Notification settings updated!

Project: my-project
Level: Custom

You will be notified for:
- New MRs
- MR assigned to you
- MR merged
- Pipeline failures
- Issue assigned to you

You will NOT be notified for:
- New issues
- Pipeline successes
- Push events
```

---

## Workflow: Mute Specific Item

**Phase 1: Get Item Details**

```bash
curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/issues/[iid]" | \
  jq '{title, subscribed}'
```

**Phase 2: Confirm Mute**

```
🔕 Mute Notifications

Item: #123 "Login bug discussion"
Current: Subscribed (receiving notifications)

Activity on this item:
- 12 comments in last week
- 3 participants

Muting will stop all notifications for this item.
You can still view it and participate.

Mute this item?
```

**Phase 3: Mute**

```bash
# Unsubscribe from issue
curl --request POST \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/issues/[iid]/unsubscribe"

# Unsubscribe from MR
curl --request POST \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/merge_requests/[iid]/unsubscribe"
```

**Phase 4: Report Result**

```
✅ Notifications muted for #123

You will no longer receive notifications for:
- New comments
- Status changes
- Mentions in this item

To unmute: /gl-notify watch #123
```

---

## Workflow: Watch Specific Item

```bash
# Subscribe to issue
curl --request POST \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/issues/[iid]/subscribe"

# Subscribe to MR
curl --request POST \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/merge_requests/[iid]/subscribe"
```

```
✅ Now watching #123

You will receive notifications for:
- All comments
- Status changes
- Any updates

Tip: You can mute anytime with /gl-notify mute #123
```

---

## Notification Levels

| Level | Description |
|-------|-------------|
| `disabled` | No notifications |
| `participating` | Only when mentioned or participating |
| `watch` | All activity |
| `global` | Use global setting |
| `custom` | Choose specific events |

---

## Smart Features

1. **Activity summary**: Show notification volume before changing
2. **Quiet hours**: Suggest muting high-traffic items
3. **Important detection**: Never mute assigned items automatically
4. **Batch operations**: Mute/watch multiple items at once

---

## Error Handling

- **Already muted**: Item is already muted
- **Already watching**: Item is already watched
- **Cannot subscribe**: Private item, no access
