# What Deserves an Anki Card? A Community-Sourced Guide

Synthesized from: Piotr Wozniak (SuperMemo), Michael Nielsen, Andy Matuschak, Gwern Branwen, Control-Alt-Backspace, Fernando Borretti, and the Anki community.

---

## Decision Frameworks

### Nielsen's 10-Minute Rule
"If memorizing a fact seems worth 10 minutes of my time in the future, then I do it."
Exception: "If a fact seems striking then into Anki it goes, regardless."

### Gwern's 5-Minute Rule
If over your lifetime you will spend more than 5 minutes looking something up, or will lose more than 5 minutes as a result of not knowing it, memorize it.

### Matuschak's Repeated Friction Test
If you "constantly pause to consult references" while doing real work, that friction is the signal to encode. You are already paying the lookup cost repeatedly -- memorization is the optimization.

### Wozniak's Priority Hierarchy
1. **Rules and principles** (highest value -- broadly applicable)
2. **Foundational/basic facts** (stable, low maintenance, prevent costly lapses)
3. **Specific facts in service of understanding** (only after #1 and #2 are covered)
4. **Never:** things you don't understand, isolated trivia, lists for their own sake

### The Three-Question Filter (Control-Alt-Backspace)
Before creating any card, ask:
1. **Do I understand this?** (If no, go learn it first.)
2. **Do I care about this?** (If no, skip it.)
3. **Does this connect to what I know?** (If no, it will become an orphan and likely fail.)

### The Creative Project Test (Nielsen / Matuschak)
Cards are most valuable when they serve an active creative or professional project. "Am I going to USE this knowledge in something I'm actively building or doing?" Speculative stockpiling ("this might be useful someday") leads to burdensome decks.

---

## What IS Worth Cards

### High-Value Card Categories (in priority order)

1. **Rules, principles, and mental models** -- broadly applicable knowledge that shapes thinking
   - "Why can't quantum teleportation transmit information faster than light?" → "Because Alice must send Bob two bits of classical information, limited by the speed of light"
   - These are the highest-ROI cards because they transfer across contexts

2. **Causal explanations and "why" questions** -- understanding mechanisms, not just labels
   - "Why do we use bones to make chicken stock?" → "They're full of gelatin, which produces a rich texture"
   - Nielsen: cards about AlphaGo progressed from "What's the size of a Go board?" (orientation) to "What were the two main types of neural network AlphaGo used?" (architecture) to deep causal cards

3. **Distinctions that are easy to confuse** -- things you'll mix up without active maintenance
   - "When creating a Unix soft link, in what order do linkname and filename go?" → "filename linkname"
   - Nielsen specifically broke this out after repeatedly getting the argument order wrong

4. **Key relationships and connections between concepts**
   - "How is stock different from soup broth?" → "Broth has complete flavor; stock is a building block"
   - Cards that build webs of knowledge rather than isolated dots

5. **Counterintuitive or surprising facts** -- things your intuition gets wrong
   - "Why is the quantum search algorithm unlikely to be useful for searching databases?" → "Well-designed databases use indices, which are faster than quantum search"
   - These reshape thinking and are worth remembering even without immediate application

6. **Core notation and terminology you'll encounter repeatedly**
   - "What does |0⟩ represent in ket notation?" → "The column vector [1; 0]"
   - Only when you'll encounter this notation regularly in your work

7. **Procedures you use repeatedly** (one step per card)
   - But only if you actually perform the procedure. Memorizing steps you'll only do once is waste.

8. **Misconception inoculation** -- what something is NOT
   - "Is it possible to use quantum teleportation to transmit information faster than light?" → "No"
   - "Does CAP theorem's 'consistency' mean the same as ACID 'consistency'?" → "No — CAP consistency means linearizability; ACID consistency means satisfying application invariants"
   - Quantum Country uses these extensively alongside definitional cards

### Card Type Distribution Target
Based on Quantum Country's 112+ cards and Nielsen's patterns:
- ~40% conceptual understanding and "why/how" cards
- ~30% core definitions and notation
- ~20% application, reasoning, and "what happens if" cards
- ~10% counterintuitive facts and misconception inoculation

---

## What is NOT Worth Cards

### The Trivia Test
Ask: "Would a practitioner need this fact to USE or APPLY the concept?" If not, skip it.

Specific anti-patterns:

1. **Historical trivia** -- year something was published, who invented it, where it was first used
   - BAD: "When was the CAP theorem proved?" → "2002"
   - BAD: "Who discovered the quantum search algorithm?" → "Lov Grover"
   - UNLESS: the historical context itself is what you're studying (e.g., history of computing course)

2. **Acronym expansions** -- what letters stand for
   - BAD: "What does SYN stand for in TCP?" → "Synchronize"
   - GOOD: "What is the purpose of the SYN packet in TCP?" → "To initiate a connection and propose an initial sequence number"
   - The expansion is trivially lookupable; the function is what matters

3. **Specific constant values** without understanding why
   - BAD: "What is the common RSA public exponent?" → "65537"
   - GOOD: "Why is a small public exponent used in RSA?" → "It makes encryption fast (fewer multiplications)"

4. **Label-only cards** -- naming things without understanding what they do
   - BAD: "What is the name of the Cas9 recognition sequence?" → "PAM"
   - GOOD: "What role does the PAM sequence play in CRISPR?" → "It signals Cas9 where to bind and begin unwinding DNA"
   - Control-Alt-Backspace: "If you can name all the parts but don't know what they do, you understand nothing."

5. **Orphan facts** -- single isolated cards disconnected from everything else
   - Nielsen: "Never add a single isolated question. Always create at least 2-3 related cards minimum."
   - Matuschak: "Orphan questions start to feel like a burden, disconnected from what you actually care about."
   - Minimum cluster size: 2-3 cards that reinforce each other

6. **Information with no retrieval context** -- facts you'd never need to recall unprompted
   - If you'd only ever need this fact while already reading about the topic (i.e., recognition, not recall), it doesn't need a card.

7. **Easily derived information** -- facts that follow logically from things you already know
   - If card A says "RSA uses a public key for encryption" and card B says "RSA uses a private key for decryption", these are trivially deducible from each other. Keep one, drop the other, or merge into a card that tests the non-obvious aspect.
   - Matuschak: "Details that aren't intuitive deserve cards; obvious inferences do not."

---

## Scaling: How Many Cards for a Topic?

### Scale to Topic Complexity, Not Input Length
A single sentence about a rich topic should still generate many cards. A long paragraph about a simple topic might only need 2-3.

### Nielsen's Progressive Depth Model
When learning from a paper or topic:
- **First pass (5-10 cards):** Basic orientation. Key terms, core definitions, what the thing IS.
- **Second pass (5-10 more):** Mechanisms and relationships. HOW it works, WHY it matters.
- **Deep pass (5-10 more):** Implications, edge cases, connections to other knowledge, misconceptions.

### Practical Calibration
- Simple concept (one mechanism): 3-5 cards
- Medium concept (multiple interacting parts): 8-15 cards
- Complex system (many components, relationships, edge cases): 15-25 cards
- Full paper or chapter: 20-50+ cards across multiple passes

### The Orphan Test
If a topic would only generate 1 card, either:
1. The topic is too simple to need a card (skip it), or
2. You haven't thought deeply enough about what's worth knowing (dig deeper)

Minimum viable cluster: 3 cards per topic.

---

## Golden Examples from the Community

### From Quantum Country (Matuschak & Nielsen) -- Progressive Depth

Basic definitional:
- "How many computational basis states does a qubit have?" → "2"

Notational fluency:
- "What is |0⟩ when written as a conventional vector?" → "[1; 0]"

Conceptual understanding:
- "What's a geometric interpretation of U being a unitary matrix?" → "It preserves the length of all input vectors"

Deep reasoning:
- "Why would a neutrino make a good quantum wire?" → "It interacts very weakly with other matter, so the quantum state is very stable"
- "Why would a neutrino make a bad qubit?" → "It interacts very weakly with other matter, so it's hard to manipulate in a controlled fashion"

Misconception inoculation:
- "Is it possible to use quantum teleportation to transmit information faster than light?" → "No"
- "Why can't quantum teleportation be used to transmit a quantum state faster than light?" → "Alice must send Bob two bits of classical information, limited by light speed"

### From Nielsen -- Atomicity Demonstration

Bad (multi-fact):
- "How to create a soft link?" → "ln -s filename linkname"

Good (split into atomic cards):
- "What's the basic command and option to create a Unix soft link?" → "ln -s ..."
- "In ln -s, what order do filename and linkname go?" → "filename linkname"

### From Matuschak -- Chicken Stock Worked Example

Factual:
- "What type of chicken parts are used in stock?" → "Bones"
- "Ratio of chicken bones to water in stock?" → "A quart of water per pound of bones"

Why/causal:
- "Why do we use bones to make chicken stock?" → "They're full of gelatin, which produces a rich texture"
- "Why don't stocks usually have distinctive flavor?" → "To make them more versatile"

Application (behavioral prompts that program attention):
- "What should I ask if using water in savory cooking?" → "'Should I use stock instead?'"

### From Wozniak -- The Dead Sea Decomposition

Bad (complex multi-fact card):
- "What are the characteristics of the Dead Sea?" → "Salt lake on the border of Israel and Jordan. Its shoreline is the lowest point on Earth's surface..."

Good (atomic):
- "Where is the Dead Sea located?" → "On the border between Israel and Jordan"
- "What is the lowest point on the Earth's surface?" → "The Dead Sea shoreline"
- "How much saltier is the Dead Sea compared with the oceans?" → "7 times"

### From Borretti -- Bidirectional Pattern

Only for genuine bidirectional recognition needs:
- "What are US Treasury bonds nicknamed?" → "Treasuries"
- "What is nicknamed 'treasuries'?" → "US Treasury bonds"

### From Control-Alt-Backspace -- Context Fixes Ambiguity

Bad: "The Articles of Confederation had no power to regulate {___}"
(Infinite valid answers)

Good: "Economic and trade relations between states were difficult under the Articles of Confederation because they granted no power to {{c1::regulate commerce}}."
(Context makes the answer unambiguous)

---

## Mirror-Card Redundancy Check

Before finalizing a card set, check: can any card's answer be trivially deduced from another card?

Examples of redundant pairs:
- "What key encrypts in RSA?" → "Public key" + "What key decrypts in RSA?" → "Private key"
  - If you know one, you know the other. Keep one, or merge: "In RSA, the {{c1::public}} key encrypts and the {{c2::private}} key decrypts"
- "NHEJ causes gene knockout" + "HDR enables gene insertion"
  - If only two repair pathways exist and you know one does knockout, the other must do insertion.

Fix: merge into multi-cloze, drop the deducible card, or reframe to test a non-obvious aspect.

---

## Cloze Difficulty Check

The deleted element should NOT be guessable from surrounding context alone.

Bad: "The {{c1::mitochondria}} is the powerhouse of the cell"
(Famous phrase -- pattern matching, not retrieval)

Bad: "TCP uses a {{c1::three}}-way handshake"
(If you know it's a handshake, "three" is the most common number associated with it)

Good: "TCP's three-way handshake sequence is: {{c1::SYN}} → SYN-ACK → ACK"
(Requires knowing the actual first step, not just a number)

Test: cover the blank. Could someone who doesn't know the topic guess it from the surrounding words? If yes, rewrite.

---

## Sources

- Piotr Wozniak, "20 Rules of Formulating Knowledge" (supermemo.com)
- Michael Nielsen, "Augmenting Long-term Memory" (augmentingcognition.com)
- Andy Matuschak, "How to Write Good Prompts" (andymatuschak.org/prompts/)
- Andy Matuschak, notes on spaced repetition (notes.andymatuschak.org)
- Matuschak & Nielsen, "How Can We Develop Transformative Tools for Thought?" (numinous.productions)
- Gwern Branwen, "Spaced Repetition for Efficient Learning" (gwern.net)
- Control-Alt-Backspace, "Rules for Designing Precise Anki Cards" (controlaltbackspace.org)
- Fernando Borretti, "Effective Spaced Repetition" (borretti.me)
- Quantum Country, "Quantum Computing for the Very Curious" (quantum.country)
