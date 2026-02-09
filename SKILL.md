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

Not everything is worth a card. This is the hardest part — most bad decks fail on selection, not formatting.

**The practitioner test:** "Would someone need this fact to USE or APPLY the concept?" If not, skip it.

**Priority hierarchy** (make cards in this order):
1. **Rules, principles, mental models** — broadly applicable knowledge that shapes thinking (highest value)
2. **Causal explanations ("why/how")** — mechanisms, not just labels. "Why does X happen?" beats "What is X?"
3. **Distinctions that are easy to confuse** — things you'll mix up without active maintenance
4. **Counterintuitive facts** — things your intuition gets wrong, misconceptions to inoculate against
5. **Key relationships** — how concepts connect to each other
6. **Core notation/terminology** — only if you'll encounter it repeatedly

**Card type distribution target:**
- ~40% conceptual understanding and "why/how" cards
- ~30% core definitions and notation
- ~20% application, reasoning, and "what happens if" cards
- ~10% counterintuitive facts and misconception inoculation

**SKIP these — they are not worth cards:**
- **Historical trivia:** year published, who invented it, where it was first used (unless studying history)
- **Acronym expansions:** what letters stand for. Card the FUNCTION, not the name. Bad: "What does SYN stand for?" Good: "What is the purpose of the SYN packet in TCP?"
- **Specific constant values** without understanding why they matter
- **Label-only cards:** naming things without testing what they DO. Bad: "What is the name of the Cas9 recognition sequence?" Good: "What role does the PAM sequence play in CRISPR?"
- **Orphan facts:** a single isolated card with no related cards. Prefer clusters of 2+ related cards, but never pad with redundant cards to hit a number.
- **Mirror-deducible cards:** if knowing card A trivially gives you card B, drop one or merge into multi-cloze. E.g., "public key encrypts" + "private key decrypts" — keep one or merge.
- **Easily derived information:** if it follows logically from another card you already made, skip it.

**Make cards FROM the provided content only:**
Cards should be based on what was actually taught or pasted — not on your general knowledge of the topic. If the user pastes an article about CRISPR that covers Cas9 but not Cas12, don't make cards about Cas12.

Exception: if you believe something critically important is MISSING from the content, flag it to the user: "The content didn't cover X, which is important for understanding this topic — want me to add cards for that too?" Only add extra cards if they say yes.

**Scaling:**
Scale card count to the amount of card-worthy content provided:
- Short explanation (1-2 key ideas): 3-5 cards
- Medium explanation (several concepts): 8-15 cards
- Long/detailed content (many concepts, relationships): 15-25 cards
Never rephrase the same fact multiple ways to hit a count. Every card must test a DIFFERENT piece of knowledge from the source content. If the content only has 1-2 card-worthy facts, make 1-2 cards. Quality over quantity — a single excellent card beats three redundant ones.

**Mirror-deducible card check (CRITICAL — do this before presenting):**
Scan your card set. If knowing card A's answer trivially gives you card B's answer, you have a mirror pair. Drop one card or merge into a single multi-cloze.

Common mirror patterns to catch:
- Encrypt/decrypt pairs: "public key encrypts" + "private key decrypts" — if there are only two keys, knowing one tells you the other. Merge: "In RSA, the {{c1::public}} key encrypts and the {{c2::private}} key decrypts."
- Sacrifice/gain pairs: "CP sacrifices availability" + "AP sacrifices consistency" — these are the same fact from two angles. Keep ONE card: "A CP system sacrifices {{c1::availability}} during a partition."
- Variant triads: "Batch uses all data" + "SGD uses one example" + "Mini-batch uses a subset" — these are a set where knowing any two gives you the third. Collapse into fewer cards that test the INTERESTING distinction: "Why is SGD often preferred over batch gradient descent?" → "Faster per update and the noise helps escape shallow local minima."

**Cloze difficulty check:** The deleted element must NOT be guessable from surrounding context alone.

Bad: "Cassandra is classified as an {{c1::AP}} system because it prioritizes availability"
(The words "prioritizes availability" directly give away "AP")

Good: "Cassandra is classified as a {{c1::AP}} system in the CAP theorem."
(No surrounding hints — requires actual knowledge)

Bad: "The {{c1::mitochondria}} is the powerhouse of the cell"
(Famous phrase — pattern matching, not retrieval)

Good: "Mitochondria generate ATP via the {{c1::electron transport chain}} in the inner membrane."
(Requires specific knowledge, not just a famous saying)

### Step 2: Generate Cards Following Quality Rules

#### Cardinal Rules (with real examples of bad → good)

**Atomic (minimum information principle):** Each card tests exactly ONE piece of knowledge. This is the most important rule and applies to BOTH the front AND the back.

The front must ask one thing. The back must be the SHORTEST correct answer — ideally 1-8 words. Resist the urge to explain or add context in the back. If you want to add context, that's a separate card.

**Back brevity test:** The back should be as short as possible — aim for under 10 words. If the back has "and" joining two distinct facts, a dash followed by elaboration, or more than one sentence — it needs splitting or trimming.

Parenthetical abbreviations are OK: "Non-homologous end joining (NHEJ)", "Guide RNA (gRNA)", "Eric Brewer (2000)" — these are standard notation, not extra facts. But parentheticals that add a NEW fact are not OK: "ATP production (cellular energy generation)" adds a restatement that should be a separate card or removed.

Common violations to watch for — if ANY of these patterns appear in a back, it MUST be split or trimmed:
- "A and B" → two facts joined by "and", split
- "A — B" or "A – B" → dash-elaboration, second fact after the dash
- "A, which B" or "A, where B" → relative clause adds a second fact
- "A, introducing/causing/enabling B" → comma + participle adds a consequence
- "A (B)" where B is NOT an abbreviation → parenthetical adds a new fact
- "A because B" → back should be just A or just B, not both
- "A; B" → semicolon joins two independent facts

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

### Step 2.5: MANDATORY Self-Check (do this BEFORE presenting)

After generating your cards, STOP and run these checks. Fix violations before showing the user.

**Mirror scan:** Read every pair of cards. Ask: "If I know card A's answer, can I immediately deduce card B's answer?" Common mirror patterns:
- Encrypt/decrypt: "public key encrypts" ↔ "private key decrypts" — same fact, two angles
- Sacrifice/gain: "CP sacrifices availability" ↔ "AP sacrifices consistency" — same tradeoff
- Variant triads: batch/SGD/mini-batch — knowing two gives you the third
- Sign/verify: "sign with private" ↔ "verify with public" — trivially deducible
Fix: merge into one multi-cloze, drop the deducible card, or reframe to test a non-obvious aspect.

**Back scan:** Read every back. Does it contain "and", a dash, a semicolon, "which", or a comma followed by a verb? If yes, it probably has two facts — split it.

**Cloze scan:** For each cloze, read the sentence with the blank. Can you guess the answer from the surrounding words alone without knowing the topic? If yes, remove the hint words or restructure.

**Distribution count:** Count: how many cards are "what is X" definitions vs. "why/how" reasoning? If more than half are definitional, convert some to "why" or "what happens if" cards using the same facts.

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

### Per-card checks:
- [ ] Front asks exactly one thing
- [ ] Back is short (aim for under 10 words) — no "and" joining two facts, no dash-elaboration, no "A — this means B". Abbreviation parentheticals like (NHEJ) are fine, but new-fact parentheticals are not.
- [ ] Has one unambiguous answer (not multiple valid answers)
- [ ] Does not ask for an example (invert: state example, ask what it is)
- [ ] Is not a yes/no question
- [ ] Is not asking for a list or enumeration (including 2-item cloze lists)
- [ ] States the topic/domain for context
- [ ] If cloze: the blank is NOT guessable from surrounding words
- [ ] Not historical trivia (year, inventor) unless the user is studying history
- [ ] Not a label-only card — tests what something DOES, not just its name
- [ ] Tags are descriptive

### Whole-set checks (do these AFTER generating all cards, BEFORE presenting):
- [ ] **Mirror check:** No two cards where knowing one trivially gives you the other. Read each pair and ask "if I know card A, can I immediately answer card B?" If yes → merge or drop.
- [ ] **No repeated facts:** Every card tests a genuinely different piece of knowledge. If two cards test the same fact in different words, drop one.
- [ ] **Type distribution:** Count your cards by category. At least ~40% should be "why/how/reasoning" cards — not just "what is X?" definitions. If your set is mostly definitional, add more causal, application, and misconception cards before presenting.
- [ ] **No padding:** Every card tests a genuinely different fact. If content only supports 2 cards, make 2. Never add a third card by rephrasing. Flag thin content to the user instead.
