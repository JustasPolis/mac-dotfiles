---
name: epic-reviewer
description: Reviews Jira epics against Definition of Ready (DoR) checklist. Use when asked to "review epic", "check DoR", "definition of ready", "is this epic ready", or when a Jira epic URL is shared for readiness review.
---

# Epic Reviewer Skill

Review Jira epics against the Definition of Ready checklist to ensure they are prepared for development.

## Prerequisites

- jira cli must be configured and authenticated
- `FIGMA_TOKEN` environment variable (for auto-triggering design review when Figma links are found)

## Workflow

### Step 1: Parse Jira Input

Extract the issue key from user input:
- From URL: `https://podimo.atlassian.net/browse/PROJ-123` → `PROJ-123`
- From direct reference: `PROJ-123`

### Step 2: Fetch Epic Details

```bash
# Get epic details
jira issue view PROJ-123

# Get linked issues (stories/tasks)
jira issue list -q "parent = PROJ-123"
```

### Step 3: Review Against DoR Checklist

Parse the epic description and linked content against all 8 sections below. For each item, determine:
- ✅ **Present** - Item is documented/addressed
- ⚠️ **Missing** - Item not found, show the hint text
- ❓ **Unclear** - Partially addressed or ambiguous

---

## Definition of Ready Checklist

### 1. Clarity of Purpose (PM-owned)

| Item | Owner | Hint when missing |
|------|-------|-------------------|
| Background / Rationale | PM | *"Why are we building this? What's the user problem or opportunity?"* |
| Business Requirements | PM | *"What does the business need from this feature?"* |
| Success Metrics | PM + Data | *"How will we measure success (activation, retention, engagement)?"* |

### 2. Scope and Expectations

| Item | Owner | Hint when missing |
|------|-------|-------------------|
| Acceptance Criteria | PM | *"What does 'done' look like? Clear user-facing and technical expectations."* |
| Out of Scope | PM | *"What are we intentionally not solving here?"* |
| Edge Cases / Error States | Design + Eng | *"List known exceptions or unusual behaviours (e.g. layout edge cases)."* |

### 3. Design Readiness (Design-owned)

**If a Figma link is found in the description, automatically trigger the `design-reviewer` skill.**

| Item | Owner | Hint when missing |
|------|-------|-------------------|
| Design marked "Ready for Dev" in Figma | Design | *Link to Figma with designs* |
| Mobile & tablet sizes covered | Design | *Phone and tablet layouts present* |
| Localisation considered | Design | *Text expansion room for translations* |
| Empty/error states included | Design | *Loading, empty, error states designed* |
| Accessibility guides included | Design | *A11y considerations documented* |
| Design walkthrough with team | Design | *Confirm walkthrough has occurred* |

### 4. Technical Readiness (Eng-owned)

| Item | Owner | Hint when missing |
|------|-------|-------------------|
| **Tech Lead appointed** | Eng | *"Who is the tech lead responsible for this epic?"* |
| Epic created in Jira | Eng | *Link to Jira Epic* |
| Notion page created | Eng | *Link to Notion documentation page* |
| Slack channel for communication | Eng | *Link to dedicated Slack channel* |
| Dependencies, Risks, Constraints identified | PM + Eng | *"Any external teams involved (e.g. AI)? Any blocked paths?"* |
| Epic broken into stories/tasks | Eng | *Child issues exist and are linked* |
| Tasks are estimated (T-shirt size) | Eng | *Story points or T-shirt sizes assigned* |
| Tasks are prioritised | Eng | *Priority/order is clear* |
| Deeplinks check
| QA/Testing (Dogfooding) Plan | Eng | *"How will this be tested before release?"* |


### 5. Experimentation Setup (if applicable)

*This section applies when the epic involves A/B testing or feature experiments.*

| Item | Owner | Hint when missing |
|------|-------|-------------------|
| A/B test requirements documented | PM | *Document experiment requirements* |
| Experiment brief filled | PM | *Link to experiment brief document* |
| Regions defined | PM | *Default: all regions* |
| User split % defined | PM | *Default: 50/50* |
| Trigger condition defined | PM | *"When should this experiment trigger?"* |
| Power calculations | Product Analytics | *Statistical power analysis completed* |
| Feature Toggle in Growthbook | Eng | *Toggle created and configured* |
| Experiment created in Growthbook | Eng | *PM to fill hypothesis, description* |
| Launch decision documented | PM + Analytics | *"What are the success criteria and next steps?"* |

### 6. Tracking & Analytics

| Item | Owner | Hint when missing |
|------|-------|-------------------|
| Tracking events defined | PM + Eng | *List of events to track* |
| Aligned with stakeholders | PM + Eng | *Coordinated with Product Analyst / CRM* |
| Reference Mobile Events List | Eng | *See: Mobile events list in Confluence* |
| Kibana dashboard requirements | Eng | *Link to dashboard or requirements* |

### 7. Team Alignment

| Item | Owner | Hint when missing |
|------|-------|-------------------|
| Presented at backlog refinement | PM + Design + Eng Lead | *Confirm presentation has occurred* |
| Product Analyst review completed | PM | *"Aligned on tracking & outcomes"* |
| Technical feasibility reviewed | Eng | *Engineering has validated approach* |
| Rollout/Comms/Go-to-Market plan | PM | *"Internal and external comms considered?"* |

### 8. Communication

| Item | Owner | Hint when missing |
|------|-------|-------------------|
| Public Slack channel created | Team | *Link to Slack channel for epic communication* |

---

## Step 4: Auto-trigger Design Review

If a Figma link is found in the epic description:

1. Extract the Figma URL
2. Automatically invoke the `design-reviewer` skill
3. Include design review results in the final report

Pattern to match: `figma.com/design/` or `figma.com/file/`

## Step 5: Generate Report

## Output Format

```
## EPIC REVIEW: [PROJ-123] Epic Title

### Overall Readiness: X/8 sections addressed

---

### 1. Clarity of Purpose
- Background/Rationale: ✅ Present
- Business Requirements: ⚠️ Missing
  → "What does the business need from this feature?"
- Success Metrics: ⚠️ Missing
  → "How will we measure success (activation, retention, engagement)?"

### 2. Scope and Expectations
- Acceptance Criteria: ✅ Present
- Out of Scope: ⚠️ Missing
  → "What are we intentionally not solving here?"
- Edge Cases / Error States: ❓ Unclear
  → "List known exceptions or unusual behaviours."

### 3. Design Readiness
- Figma link: ✅ Found → [Auto-triggered design-reviewer]
- Mobile & tablet sizes: [from design-reviewer]
- Localisation: [from design-reviewer]
- Empty/error states: [from design-reviewer]
- Accessibility guides: ⚠️ Missing
- Design walkthrough: ❓ Unclear

### 4. Technical Readiness
- Tech Lead: ⚠️ Not appointed
  → "Who is the tech lead responsible for this epic?"
- Epic in Jira: ✅ Present (this epic)
- Notion page: ⚠️ Missing
  → Link to Notion documentation page
- Slack channel: ⚠️ Missing
  → Link to dedicated Slack channel
- Dependencies/Risks: ✅ Present
- Stories/Tasks breakdown: ✅ Present (X child issues found)
- Tasks estimated: ⚠️ Missing
  → Story points or T-shirt sizes not assigned
- Tasks prioritised: ✅ Present
- QA/Testing Plan: ⚠️ Missing
  → "How will this be tested before release?"

### 5. Experimentation Setup
- [Mark as N/A if no A/B testing mentioned, otherwise review items]

### 6. Tracking & Analytics
- Tracking events: ⚠️ Missing
  → List of events to track
- Stakeholder alignment: ❓ Unclear
- Kibana dashboard: ⚠️ Missing
  → Link to dashboard or requirements

### 7. Team Alignment
- Backlog refinement: ❓ Unclear
  → Confirm presentation has occurred
- PA review: ⚠️ Missing
  → "Aligned on tracking & outcomes"
- Technical feasibility: ✅ Present
- Rollout/GTM plan: ⚠️ Missing
  → "Internal and external comms considered?"

### 8. Communication
- Slack channel: ⚠️ Missing
  → Link to Slack channel for epic communication

---

### Linked Reviews
- Design Review: ✅ Triggered / ⚠️ No Figma link found

### Summary
**Advisory Status:** X items need attention before sprint start

**Priority items to address:**
1. [Most critical missing items]
2. [...]

**Optional improvements:**
- [Nice-to-have items]
```

## Status Legend

| Status | Meaning |
|--------|---------|
| ✅ Present | Item is documented and complete |
| ⚠️ Missing | Item not found - action required |
| ❓ Unclear | Partially addressed or needs clarification |
| N/A | Not applicable for this epic |

## Notes

- This review is **advisory** - it highlights gaps but does not block development
- Section 5 (Experimentation) should be marked N/A if the epic doesn't involve A/B testing
- Always show the hint text for missing items to guide the team on what's needed
- The design-reviewer integration provides detailed Figma analysis when links are present
