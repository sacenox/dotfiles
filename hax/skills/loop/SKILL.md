---
description: Use when the user explicitly asks to run the worker/adversary loop.
---

# Worker / adversary loop

Coordinate the `worker` and `adversary` skills to work through the user's request from opposing perspectives.

Use the `worker` skill to produce or update the solution. Then use the `adversary` skill to challenge its direction, assumptions, and result from an independent point of view. Do not frame the adversary as a code reviewer or limit it to finding defects.

Feed useful challenges, alternatives, and missed considerations back through the `worker` skill while preserving the user's original intent and scope. Alternate between the two skills until another pass produces no meaningful change, or progress requires a decision from the user.

Do not introduce scope or change the solution away from the user request during the loop.
