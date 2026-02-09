---
name: anki-card-maker
description: Create high-quality Anki flashcards from learned content and push them to Anki via AnkiConnect. Use when (1) you have just taught the user something and they may benefit from retaining it — offer to create cards, (2) the user explicitly asks to make Anki cards, flashcards, or spaced repetition cards from content they paste or describe, or (3) the user says "I learned X, make cards for it." This skill identifies what is worth remembering, generates cards following spaced repetition best practices, shows them for approval, then pushes to Anki.
---

# Anki Card Maker

## Two Trigger Modes

### Mode 1: After Teaching
When you have just explained a concept or taught the user something substantive, ask:

> "Want me to make Anki cards for the key concepts from this?"

Only proceed if they say yes. Do NOT auto-generate cards without confirmation.

### Mode 2: Explicit Request
The user directly asks to create cards. Proceed immediately.

## Card Creation Process

### Step 1: Identify What Deserves a Card

Not everything is worth a card. Select only:
- Core facts needed for unprompted recall
- Distinctions that are easy to confuse
- Key relationships and connections
- Procedure steps (one per card)

Skip: obvious-once-understood facts, easily-looked-up info, volatile facts.

### Step 2: Generate Cards Following Quality Rules

#### Cardinal Rules (with real examples of bad → good)

**Atomic (minimum information principle):** Each card tests exactly ONE piece of knowledge. This is the most important rule and applies to BOTH the front AND the back.

The front must ask one thing. The back must be the SHORTEST correct answer — ideally 1-8 words. Resist the urge to explain or add context in the back. If you want to add context, that's a separate card.

**Back brevity test:** The back should be as short as possible — aim for under 10 words. If the back has "and" joining two distinct facts, a dash followed by elaboration, or more than one sentence — it needs splitting or trimming.

Parenthetical abbreviations are OK: "Non-homologous end joining (NHEJ)", "Guide RNA (gRNA)", "Eric Brewer (2000)" — these are standard notation, not extra facts. But parentheticals that add a NEW fact are not OK: "ATP production (cellular energy generation)" adds a restatement that should be a separate card or removed.

Common violations to watch for:
- Front: "Who invented X and when?" → split into who and when
- Front: "What does X sacrifice and when would you use it?" → two cards
- Back: "It does A and B" → one card for A, one for B
- Back: "X because (1) reason, (2) reason" → one card per reason
- Back: "X (also known as Y)" → trim the parenthetical unless that's what the card tests
- Back: "A — this means B" → the dash adds a second fact, remove it or make it a separate card
- Back: "A, which enables B" → two facts, split

Bad: "What type of cryptography is RSA?" → "Asymmetric (public-key) cryptography — it uses a pair of keys: one public, one private."
(Answers the question, then adds extra context after a dash)

Good:
- "What type of cryptography is RSA?" → "Asymmetric (public-key) cryptography"
- "RSA: How many keys does each participant have?" → "Two: one public, one private"

Bad: "What is the RSA public key composed of?" → "The pair (n, e) — the modulus and public exponent"
(Lists two components AND explains what they are)

Good:
- "RSA: What is the first component of the public key?" → "The modulus n"
- "RSA: What is the second component of the public key?" → "The public exponent e"

Bad: "How to add a column to a pandas dataframe?" → "df.insert(index, name, data)"
(Combines the method name AND the argument order)

Good:
- "Pandas: What method adds a column to a dataframe?" → "df.insert()"
- "Pandas: What is the argument order for df.insert()?" → "index, name, data"

**One unambiguous answer:** If a reviewer could give a different-but-valid answer, the card is broken.

Bad: "The Articles of Confederation had no power to regulate ___"
(Infinite valid fills: commerce, taxation, religion, etc.)

Good: "Economic and trade relations between states were difficult under the Articles of Confederation because they granted no power to {{c1::regulate commerce}}."
(Context narrows it to exactly one answer)

**No asking for examples:** NEVER write "What is an example of X?" or "Give an example of X." These have multiple valid answers and overfit to one instance. Always invert: state the example, ask what it exemplifies.

Bad: "What's an example of a non-combinatorial circuit?" → "Memory"
Bad: "What is an example of a CP data store?" → "MongoDB"
(Both have multiple valid answers — the reviewer could name any valid instance)

Good: "Memory is an example of a {{c1::non-combinatorial}} circuit."
Good: "MongoDB (with majority write concern) is classified as a {{c1::CP}} system in the CAP theorem."
(Tests the concept using a specific example, not the other way around)

**No enumerations, even disguised as cloze:** Never ask "list all X" or "name the N things." A cloze with multiple fills listing distinct items is still an enumeration — even with just 2 items. If each fill is an independent fact (e.g., two enzyme names, two steps, two components), split into separate cards.

Bad (cloze enumeration): "The three CAP guarantees are {{c1::Consistency}}, {{c2::Availability}}, {{c3::Partition Tolerance}}."
Bad (2-item cloze enumeration): "Cas9 has two domains: {{c1::RuvC}} and {{c2::HNH}}."
(Both are lists in cloze clothing — each fill is an independent fact)

Good — separate cards:
- "CAP theorem: What does Consistency guarantee?" → "Every read receives the most recent write or an error."
- "CAP theorem: What does Availability guarantee?" → "Every request receives a non-error response."
- "CRISPR: Which Cas9 domain cleaves the non-complementary strand?" → "RuvC"
- "CRISPR: Which Cas9 domain cleaves the complementary strand?" → "HNH"

OK (multi-fill cloze for one concept): "The gradient descent update rule is: θ = θ − {{c1::α}} · ∇J(θ)" — this tests ONE thing (the learning rate symbol in context), not a list of items.

**No yes/no questions:** Encode the actual fact instead.

Bad: "Is segmentation used on modern processors?" → "No"
(Binary answer carries almost no information)

Good: "Segmentation was common on older processors but was removed starting with the {{c1::x86-64}} platform."

**Context-free and source-independent:**

Bad: "Statistics: One of our textbook's major points is that it's useful to measure ___"
(Depends on a specific source, won't transfer)

Good: "Statistics is not only about describing what you know but also about putting it in the context of {{c1::what you still don't know}}."

**When quoting someone's opinion, attribute it:**

Good: "Why, according to Cal Newport, are discoveries often made by multiple people at the same time?" → "Because they are part of the 'adjacent possible' — ideas that become reachable given current knowledge."

#### Card Type Selection

**basic** (front → back): single facts, cause→effect, concept→explanation.
"What gravitational effect is causing Earth's rotation to slow over time?" → "Tidal deceleration."

**reversed** (bidirectional): ONLY when recognition genuinely matters in both directions — foreign word↔translation, chemical symbol↔element name. Do NOT use reversed for general Q&A.
"Fe" ↔ "Iron (element 26)"

**cloze** (fill-in-the-blank): when surrounding context aids recall or the fact reads more naturally as a statement.
"The gradient descent update rule is: θ = θ − {{c1::α}} · ∇J(θ), where {{c1}} is called the learning rate."

#### Tag Strategy

Use descriptive tags:
- Topic-level: `machine-learning`, `calculus`, `biology`
- Subtopic: `backpropagation`, `derivatives`, `genetics`
- Type tags when useful: `definition`, `formula`, `process`

### Step 3: Present for Approval

Display ALL generated cards in a markdown table. The table MUST have exactly 5 columns and ONE row per card. Never merge Front and Back into one column. Never split a card across multiple rows.

```
| # | Type | Front / Text | Back / Extra | Tags |
|---|------|-------------|-------------|------|
| 1 | basic | What is X? | Y | topic, subtopic |
| 2 | cloze | {{c1::Term}} is defined as... | | topic |
| 3 | reversed | Fe | Iron (element 26) | chemistry |
```

Do NOT use these formats:
- `**F:** question **B:** answer` in one cell (wrong — use separate columns)
- Multi-row cards where Back is on a second row (wrong — one row per card)
- `question → answer` in one cell (wrong — use separate columns)

Ask: "These look good? I'll push them to Anki. Edit any you'd like to change."

Wait for explicit approval before pushing.

### Step 4: Push to Anki

After approval, write the cards as JSON and run the push script:

```bash
python /Users/julianmoncarz/Skills/anki-card-maker/scripts/push_to_anki.py cards.json --deck "Default"
```

JSON format:
```json
[
  {"type": "basic", "front": "Q", "back": "A", "tags": ["topic"]},
  {"type": "cloze", "text": "{{c1::Term}} does X.", "tags": ["topic"]},
  {"type": "reversed", "front": "Term", "back": "Definition", "tags": ["topic"]}
]
```

If AnkiConnect is not running, tell the user to open Anki and ensure the AnkiConnect addon (code 2055492159) is installed.

## Quality Checklist (verify EVERY card before presenting)

- [ ] Front asks exactly one thing
- [ ] Back is short (aim for under 10 words) — no "and" joining two facts, no dash-elaboration. Abbreviation parentheticals like (NHEJ) are fine.
- [ ] Has one unambiguous answer (not multiple valid answers)
- [ ] Does not ask for an example (invert: state example, ask what it is)
- [ ] Is not a yes/no question
- [ ] Is not asking for a list or enumeration (including 2-item cloze lists)
- [ ] States the topic/domain for context
- [ ] Uses the most appropriate card type
- [ ] Tags are descriptive
