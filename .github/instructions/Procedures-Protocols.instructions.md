````instructions
---
applyTo: "Procedural-Memory/**/*.md"
description: Protocol Creation and Execution Standards
---

# Catalyst Protocol Instructions

## Protocol Creation Standards

Protocols are your reference playbooks for recurring situations. Create them when:
- A sequence of steps solves a category of problems
- You discover an optimal order of operations
- Success criteria are clear and repeatable
- The protocol saves 20+ minutes on future occurrences

### Protocol Template
```markdown
# [Protocol Name]

## Purpose
[What problem does this solve? When should you use it?]

## Prerequisites
[What must be true before starting?]

## Steps
1. [Clear, specific step with expected output]
2. [Next step - what changes after step 1?]
3. [Continue...]

## Expected Outcome
[What does success look like? What's verified?]

## Common Failure Modes
- **Issue X**: What causes it? → Recovery: How to fix?
- **Issue Y**: Root cause? → Prevention: How to avoid?

## Time Estimate
[How long should this take? Where are delays likely?]

## Recovery Instructions
[If you get interrupted mid-protocol, where to resume?]
```

## Protocol Execution Best Practices

**BEFORE Starting**:
- Verify all prerequisites are met
- Read expected outcome to understand goal
- Scan failure modes to anticipate problems
- Allocate sufficient time

**DURING Execution**:
- Follow steps in order (don't skip ahead)
- Document any deviations and why
- Stop if unexpected situation occurs (not covered in protocol)
- Note successes and failures in real-time

**AFTER Completion**:
- Verify expected outcome is achieved
- Document any new failure modes encountered
- Update protocol if you found better sequence
- Celebrate if you completed it successfully!

## Protocol Types

### 1. System Protocols
- **initialization_protocol.md** - Starting every new session with full memory restoration
- **github_token_retrieval.md** - Safe GitHub authentication
- **restoration_guide.md** - Recovery from unexpected failures

### 2. Workflow Protocols
- **nap_protocol.md** - Pause work and preserve context for resumption
- Context-specific protocols for recurring workflows

## Creating Protocols vs Procedures vs Guidelines

**Protocol** = Specific sequence for a specific type of problem
- Example: initialization_protocol.md (specific startup sequence)
- Use for: Repeatable, complex, time-critical procedures

**Procedure** = General how-to for a capability
- Example: GitHub integration guide (covers many scenarios)
- Use for: Knowledge-based, not time-dependent, flexible approach

**Guideline** = Principles and standards to follow
- Example: Communication style, code quality standards
- Use for: General direction, principles, best practices

## Protocol Maintenance

**Monthly Review**:
- Are my protocols still accurate?
- Have I discovered better sequences?
- Should I deprecate or update any?

**Add New Protocols When**:
- You complete a complex task that you'll repeat
- You establish a valuable new pattern
- Others (future humans or AIs) need to know your process

**Archive Old Protocols When**:
- They no longer apply to your situation
- You've discovered a better approach
- Technology or constraints have fundamentally changed

## The Power of Protocol Mastery

Protocols are force multipliers:
- First time: Learn and experiment (1-2 hours, maybe fail)
- Second time: Follow protocol (20 minutes, documented success)
- Third+ time: Execute perfectly without thinking (5 minutes)

Your protocol library is your competitive advantage. Build it diligently. Use it religiously.

````