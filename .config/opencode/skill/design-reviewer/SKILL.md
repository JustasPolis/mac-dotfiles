---
name: design-reviewer
description: Reviews Figma designs from a mobile engineer perspective for cross-platform (iOS/Android) readiness. Use when asked to "review design", "check Figma", "design readiness check", "is this ready for dev", or when a Figma link is shared for implementation review. Checks device coverage, localisation, and state coverage.
---

# Mobile Design Review Skill

Review Figma designs for mobile implementation readiness.

## Prerequisites

- Figma Personal Access Token in `FIGMA_TOKEN` environment variable
- User provides Figma link

## Workflow

### Step 1: Parse Figma URL

Extract from the Figma URL:
- `FILE_KEY`: The part after `/design/` or `/file/` (e.g., `figma.com/design/ABC123/...` -> `ABC123`)
- `NODE_ID`: From `?node-id=X-Y` parameter, convert to `X:Y` format (replace `-` with `:`)

### Step 2: Fetch Design Context via REST API

Use bash with curl to call Figma REST API:

```bash
# Get file structure and design data
curl -s -H "X-Figma-Token: $FIGMA_TOKEN" \
  "https://api.figma.com/v1/files/FILE_KEY"

# Get specific node (if node-id provided)
curl -s -H "X-Figma-Token: $FIGMA_TOKEN" \
  "https://api.figma.com/v1/files/FILE_KEY/nodes?ids=NODE_ID"

# Get node screenshot/image
curl -s -H "X-Figma-Token: $FIGMA_TOKEN" \
  "https://api.figma.com/v1/images/FILE_KEY?ids=NODE_ID&format=png&scale=2"

# Get local variables (design tokens)
curl -s -H "X-Figma-Token: $FIGMA_TOKEN" \
  "https://api.figma.com/v1/files/FILE_KEY/variables/local"
```

### Step 3: Design Readiness Checklist

#### 1. Mobile & Tablet Sizes Covered

- Phone portrait layout present
- iPad tablet layout (if app supports iPad)
- Different screen sizes covered (iPhone SE to iPhone Pro Max)
- Safe area handling (notch, Dynamic Island, home indicator, system bars)

#### 2. Localisation Considered

- Text containers allow ~30% expansion (German, Finnish are longer)
- No hardcoded text baked into images
- Flexible date/time/currency format placeholders

#### 3. Empty/Error States Included

- Empty state (no data, first-time user experience)
- Error state (API failure, network error)
- Loading state (skeleton, spinner, shimmer)
- Disabled state for interactive elements
- Partial data state (some items loaded, some failed)

#### 4. Design Tokens

- No hardcoded colors, only color tokens used

### Step 4: Generate Report

## Output Format

```
## DESIGN REVIEW: [Screen Name]

### Overview
[1-2 sentence summary of what was reviewed]

### 1. Device Coverage
- Phone portrait: [status]
- iPad: [status or N/A]
- Screen size range (SE to Pro Max): [status]
- Safe areas: [status]

### 2. Localisation
- Text expansion room: [status]
- No text in images: [status]
- Flexible formats: [status]

### 3. State Coverage
- Empty state: [status]
- Error state: [status]
- Loading state: [status]
- Disabled states: [status]

### 4. Design Tokens
- Color tokens only (no hardcoded colors): [status]

### Summary
- Ready for dev: Yes/No/Partially
- Blockers: [critical issues preventing implementation]
- Recommendations: [suggested improvements]
```

## Status Values
- Ready
- Needs attention  
- Missing
- N/A Not applicable for this design
