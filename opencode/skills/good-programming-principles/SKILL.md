---
name: good-programming-principles
description: Load when designing, writing, editing, refactoring, or reviewing code. Applies KISS, DRY, YAGNI, and SOLID principles to keep solutions simple, scoped, and maintainable while avoiding overengineering.
version: 0.0.1
---

# Good Programming Principles

These principles reduce complexity, improve maintainability, and keep scope under control. Apply them together, but avoid dogma.

## KISS (Keep It Simple, Stupid)

- Favor the simplest design that solves the current problem.
- Prefer clarity over cleverness; optimize for readability.
- Reduce moving parts: fewer layers, fewer options, fewer states.
- Validate complexity with evidence (performance, scale, constraints).

Sources:
- https://en.wikipedia.org/wiki/KISS_principle
- https://www.interaction-design.org/literature/topics/keep-it-simple-stupid

## DRY (Don't Repeat Yourself)

- Keep a single source of truth for logic, rules, and data.
- Remove copy-paste by extracting shared functions or modules.
- Avoid premature abstraction; small duplication can be acceptable if it preserves clarity.
- Consider AHA (Avoid Hasty Abstractions): abstract when duplication becomes a barrier and the abstraction's shape is clear.

Sources:
- https://en.wikipedia.org/wiki/Don%27t_repeat_yourself
- The Pragmatic Programmer (1999) by Andrew Hunt & David Thomas, ISBN 978-0-201-61622-4
- http://principles-wiki.net/principles:don_t_repeat_yourself

## YAGNI (You Aren't Gonna Need It)

- Build for current requirements, not hypothetical ones.
- Defer generalization until you have a concrete use case.
- Prefer small extension points over speculative flexibility.
- Originated from Extreme Programming (XP); works best with continuous refactoring and testing.

Sources:
- https://en.wikipedia.org/wiki/You_aren%27t_gonna_need_it
- http://ronjeffries.com/xprog/articles/practices/pracnotneed/ (Ron Jeffries, XP co-founder)
- Extreme Programming Installed (2001) by Ron Jeffries et al., ISBN 0-201-70842-6

## Feature Creep

- Uncontrolled scope growth harms focus, quality, and timelines.
- Define and protect the minimum valuable feature set.
- Add features only with clear user value and acceptable cost.

Sources:
- https://en.wikipedia.org/wiki/Feature_creep
- IEEE: "Toward preprototype user acceptance testing" (Davis & Venkatesh, 2004) - identifies feature creep as top cause of cost/schedule overruns

## Overengineering

- Extra complexity beyond the problem size increases risk and slows delivery.
- Choose the smallest solution that meets real constraints.
- Avoid unnecessary frameworks, abstractions, or configurability.
- Use measurements to justify optimization or architecture changes.

Sources:
- https://en.wikipedia.org/wiki/Overengineering
- NASA Software Engineering Handbook - lists excessive features in top 10 development risks
- Harvard Business Review: "Defeating Feature Fatigue" (Rust, Thompson & Hamilton, 2006)

## SOLID

Introduced by Robert C. Martin; acronym coined by Michael Feathers (c. 2004).

- Single Responsibility: one reason to change; keep modules focused.
- Open/Closed: extend via new code, avoid modifying stable paths.
- Liskov Substitution: derived types must work in place of base types.
- Interface Segregation: small, specific interfaces; avoid fat contracts.
- Dependency Inversion: depend on abstractions, invert control at boundaries.

Sources:
- https://en.wikipedia.org/wiki/SOLID
- "Design Principles and Design Patterns" (Robert C. Martin, 2000): https://staff.cs.utu.fi/~jounsmed/doos_06/material/DesignPrinciplesAndPatterns.pdf
- Clean Architecture (2017) by Robert C. Martin, ISBN 978-0-13-449416-6
- https://www.baeldung.com/solid-principles

## Applying the Principles

- Start with KISS and YAGNI; keep scope tight and solutions simple.
- Refactor toward DRY when duplication is real and stable.
- Use SOLID as a refactoring lens, not a starting template.
- Guard against feature creep and overengineering with explicit scope checks.
