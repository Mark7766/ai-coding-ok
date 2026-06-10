<!-- ai-coding-ok: v3.1.0 -->
# 🔄 {{project-name}} — Agent Workflow Guide

> Defines the standard workflow for the AI agent in different scenarios.

---

## Scenario 1: Implement a New Feature

```
Step 1: Understand the requirement
  ├── Read the issue and acceptance criteria
  ├── Read project-memory.md for context
  ├── Confirm the feature aligns with project principles
  └── If anything is unclear, list assumptions and confirm

Step 2: Design
  ├── Identify the affected modules
  ├── Design the data model (if needed)
  ├── Choose the simplest viable approach
  └── Assess impact on existing features

Step 3: Implement
  ├── Create/modify models
  ├── Implement service-layer business logic
  ├── Implement API routes
  └── Implement page templates (if UI is needed)

Step 4: Test
  ├── Write unit tests
  ├── Write integration tests
  └── Run the full test suite to confirm no regressions

Step 5: Wrap up ⚠️ Don't skip
  ├── Update task-history.md ← required
  ├── If architectural decisions changed → update decisions-log.md
  ├── If project facts changed → update project-memory.md
  └── Commit (Conventional Commits format)
```

---

## Scenario 2: Fix a Bug

```
Step 1: Reproduce
  ├── Understand the bug description and reproduction steps
  └── Write a failing test that reproduces the bug

Step 2: Locate
  ├── Analyze the error log/stack
  ├── Trace the call chain
  └── Identify the root cause

Step 3: Fix
  ├── Fix the code
  ├── Make sure the previously failing test now passes
  └── Check whether similar issues need fixing too

Step 4: Verify
  ├── Run the full test suite
  └── Confirm there are no side effects

Step 5: Wrap up ⚠️ Don't skip
  ├── Update task-history.md ← required
  └── If this is a common pitfall → update project-memory.md
```

---

## Scenario 3: Refactor

```
Step 1: Set the goal
  ├── Why refactor? (readability/performance/maintainability)
  ├── How big is the scope?
  └── Make sure tests cover the area

Step 2: Small steps
  ├── Change one thing at a time
  ├── Run tests after each step
  └── Preserve behavior (behavior-equivalent)

Step 3: Verify
  ├── All tests pass
  └── Readability has actually improved

Step 4: Wrap up ⚠️ Don't skip
  ├── Update task-history.md ← required
  ├── If module structure changed → update project-memory.md
  └── If technical decisions were made → update decisions-log.md
```

---

## Scenario 4: Product Requirement Analysis

```
Step 1: Switch to product manager mode
  ├── Understand the user's core need
  ├── Analyze use cases
  ├── Consider edge cases
  └── Keep the project's design principles in mind

Step 2: Output
  ├── User story
  ├── Acceptance criteria
  └── Priority suggestion

Step 3: Confirm
  └── Confirm the understanding with the user
```

---

## Scenario 5: Deployment and Release

```
Step 1: Confirm deployment approach
  ├── Make sure dependencies are complete
  ├── Prepare config templates
  └── Check environment variables

Step 2: Pre-deploy checklist
  ├── Config files filled in
  ├── Database reachable
  ├── External services connect successfully
  └── Tests pass
```
