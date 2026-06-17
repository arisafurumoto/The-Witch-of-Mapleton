# Vertical Slice 0.4 - Quest and Recipe Guidance v1

> Status: COMPLETE.
> Start after Vertical Slice 0.3.1 is closed.

## Goal

Make the current Sage and cauldron loop easier to understand without adding new
content, new quest chains, or larger systems.

The player should always be able to answer:

- What am I trying to make?
- Which ingredients do I still need?
- Where does the recipe live?
- Why is Brew disabled?

## Player Problem

Root-Wake Tonic now uses different ingredients from Calming Tea, which is good for
recipe clarity, but it creates a guidance burden. The current HUD only says
`Craft Root-Wake Tonic`, and the player has to infer the ingredient checklist from
Sage's reminder or the cauldron panel.

0.4 should close that readability gap.

## Required Scope

Build only guidance and feedback for the existing 0.3.1 loop:

- Quest tracker shows ingredient progress for the active craft objective.
  - `Dewcap Mushroom 0/1`
  - `Glowberry 0/2`
- Quest tracker switches to turn-in text once Root-Wake Tonic is crafted.
  - `Bring Root-Wake Tonic to Sage`
- Cauldron recipe detail keeps showing missing ingredients clearly.
- Gather feedback tells the player what was picked up.
  - `Gathered Dewcap Mushroom x1`
  - `Gathered Glowberry x2`
- Add small item icons for Dewcap Mushroom and Glowberry in `art/items/`.
- Inventory panel should display the new ingredient icons if present.
- Sage's reminder text should remain aligned with the current Root-Wake recipe.

## Data and System Notes

Prefer small helpers over broad systems.

Likely useful additions:

```gdscript
RecipeDatabase.get_recipe_for_output(item_id: String) -> Dictionary
HUD.show_toast(message: String) -> void
```

The quest tracker can derive ingredient progress from:

- active quest turn-in item
- recipe output item
- recipe ingredients
- current inventory quantities

Avoid adding a quest journal unless the compact tracker becomes too cramped.

## Suggested Implementation Order

1. Add public `HUD.show_toast(message: String)`.
2. Make gatherables show a short gathered-item toast.
3. Add Dewcap Mushroom and Glowberry item icons.
4. Add a simple recipe lookup helper by output item.
5. Update the HUD quest objective to show ingredient progress while the quest item is
   not held.
6. Verify the tracker switches to turn-in text when Root-Wake Tonic is crafted.
7. Update docs and manual test steps.

## Non-Goals

Do not add:

- New quests.
- New NPCs.
- Recipe discovery.
- Full recipe book UI.
- Full quest journal.
- Map markers.
- Compass arrows.
- Farming or seed planting.
- Relationship or schedule systems.
- More recipes beyond the existing Calming Tea and Root-Wake Tonic.

## Manual Test Plan

1. Start a new game.
2. Talk to Sage and start `A Little Root Trouble`.
3. Confirm the tracker shows Root-Wake Tonic ingredient progress.
4. Gather Dewcap Mushroom and confirm its progress updates.
5. Gather Glowberry and confirm its progress updates.
6. Return to the cauldron and open Root-Wake Tonic.
7. Confirm missing ingredients are readable if anything is missing.
8. Brew Root-Wake Tonic.
9. Confirm the tracker changes to `Bring Root-Wake Tonic to Sage`.
10. Turn in the tonic and confirm quest completion feedback still works.

## Success Criteria

- A player can complete Sage's request without guessing the recipe ingredients.
- The current 0.1 customer sale still works.
- The current 0.3.1 cauldron UI remains compact and readable.
- No new long-term systems are introduced early.

## Implementation Notes

- `HUD.show_toast(message)` is now public and gatherables use it for pickup feedback.
- The compact quest tracker derives ingredient progress from the active quest turn-in
  item and its matching recipe output.
- Dewcap Mushroom and Glowberry now have native 16x16 inventory icons.
