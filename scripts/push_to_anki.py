#!/usr/bin/env python3
"""Push Anki cards via AnkiConnect API (localhost:8765).

Usage:
    python push_to_anki.py cards.json
    python push_to_anki.py cards.json --deck "My Deck"
    echo '[{"front":"Q","back":"A","tags":["test"]}]' | python push_to_anki.py -

Input JSON format (array of objects):
    [
        {
            "type": "basic",
            "front": "What is X?",
            "back": "X is Y.",
            "tags": ["topic", "subtopic"]
        },
        {
            "type": "cloze",
            "text": "{{c1::Python}} was created by {{c2::Guido van Rossum}}.",
            "tags": ["programming"]
        },
        {
            "type": "reversed",
            "front": "Mitochondria",
            "back": "The powerhouse of the cell",
            "tags": ["biology"]
        }
    ]

"type" defaults to "basic" if omitted.
"""

import json
import sys
import urllib.request
import urllib.error
import argparse


ANKI_CONNECT_URL = "http://localhost:8765"
DEFAULT_DECK = "Default"

MODEL_MAP = {
    "basic": "Basic",
    "reversed": "Basic (and reversed card)",
    "cloze": "Cloze",
}


def anki_request(action, **params):
    payload = json.dumps({"action": action, "version": 6, "params": params})
    req = urllib.request.Request(
        ANKI_CONNECT_URL,
        data=payload.encode("utf-8"),
        headers={"Content-Type": "application/json"},
    )
    try:
        with urllib.request.urlopen(req, timeout=10) as resp:
            result = json.loads(resp.read().decode("utf-8"))
    except urllib.error.URLError as e:
        print(f"ERROR: Cannot connect to AnkiConnect at {ANKI_CONNECT_URL}", file=sys.stderr)
        print("Make sure Anki is running and AnkiConnect addon is installed.", file=sys.stderr)
        sys.exit(1)

    if result.get("error"):
        raise RuntimeError(f"AnkiConnect error: {result['error']}")
    return result["result"]


def check_connection():
    try:
        anki_request("version")
        return True
    except SystemExit:
        return False


def build_note(card, deck):
    card_type = card.get("type", "basic")
    model = MODEL_MAP.get(card_type)
    if not model:
        raise ValueError(f"Unknown card type: {card_type}. Use: basic, reversed, cloze")

    tags = card.get("tags", [])
    if isinstance(tags, str):
        tags = [t.strip() for t in tags.split(",")]

    if card_type == "cloze":
        fields = {"Text": card["text"], "Extra": card.get("extra", "")}
    else:
        fields = {"Front": card["front"], "Back": card["back"]}

    return {
        "deckName": deck,
        "modelName": model,
        "fields": fields,
        "tags": tags,
        "options": {"allowDuplicate": False, "duplicateScope": "deck"},
    }


def push_cards(cards, deck=DEFAULT_DECK):
    if not check_connection():
        return []

    notes = [build_note(c, deck) for c in cards]
    results = anki_request("addNotes", notes=notes)

    added = 0
    failed = 0
    for i, note_id in enumerate(results):
        if note_id is None:
            print(f"  SKIP (duplicate or error): {cards[i].get('front', cards[i].get('text', ''))[:60]}", file=sys.stderr)
            failed += 1
        else:
            added += 1

    print(f"\nAdded {added} card(s) to deck '{deck}'. {failed} skipped.", file=sys.stderr)
    return results


def main():
    parser = argparse.ArgumentParser(description="Push Anki cards via AnkiConnect")
    parser.add_argument("input", nargs="?", default=None, help="JSON file path, or - for stdin")
    parser.add_argument("--deck", default=DEFAULT_DECK, help=f"Target deck (default: {DEFAULT_DECK})")
    parser.add_argument("--check", action="store_true", help="Only check AnkiConnect connection")
    args = parser.parse_args()

    if args.check:
        if check_connection():
            print("AnkiConnect is running.")
            sys.exit(0)
        else:
            sys.exit(1)

    if args.input == "-":
        cards = json.load(sys.stdin)
    else:
        with open(args.input) as f:
            cards = json.load(f)

    if not isinstance(cards, list):
        cards = [cards]

    results = push_cards(cards, deck=args.deck)
    print(json.dumps(results))


if __name__ == "__main__":
    main()
