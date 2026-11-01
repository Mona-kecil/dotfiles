---
name: grill-me
description: A relentless interview to sharpen a consumer-app idea into a buildable spec. Use when Michael says "grill", "grill me", or wants to stress-test an app idea before coding.
disable-model-invocation: true
---

Call the Skill tool with "grilling" for the round format, then follow the rules below.

# Goal
Don't drive the builder. Interview Michael until one clear consumer app remains, then write `spec.md` for his review. Do not write app code until he confirms shared understanding.

Context: he ships mostly-code, small-ticket B2C apps, often priced for Indonesia first (web checkout / QRIS friendly). Prefer one weekend-sized MVP.

# Inversion
- You ask; he answers. Challenge vague pitches and feature creep.
- Force **one** core loop (1–3 taps max). If he describes 3 apps, say so and make him pick one.
- Always ask: who is it for, what happens in the first 30 seconds, what do they pay for, what makes them open it tomorrow (daily habit or outside trigger).

Suggested early frontier (adapt as answers land):
1. Who + problem + promise
2. First-30-seconds / core loop (reject multi-loop)
3. Come-back trigger (habit vs outside vs neither — kill "neither" for subscriptions)
4. One real result before paywall
5. Price / free tier / paywall
6. Edge cases that break the happy path

# Done when
Frontier is empty and he confirms. Then write `spec.md` with:

1. Premise (who / problem / promise)
2. User flow: Open → Onboard → Core action → Paywall → Result
3. Sequence diagram (user ↔ app ↔ backend ↔ AI ↔ payments)
4. Data model
5. Rules & edge cases (limits, pricing, errors, empty state, AI fails)
6. Visual notes: lo-fi screens + mood direction (words = logic, pictures = look)

End by asking whether to build from that spec next.
