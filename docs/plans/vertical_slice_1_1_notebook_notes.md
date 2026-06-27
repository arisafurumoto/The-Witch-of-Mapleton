# Vertical Slice 1.1 - Marigold's Notebook / Quest and Recipe Notes v1

> Status: PLANNED.
> Start after Vertical Slice 1.0 is committed or otherwise safely backed up.

## Goal

Add a compact notebook UI that helps the player understand the current authored quest
chain and known recipes without adding more world content.

The project now has Sage's request, Camellia's shop request, Camellia's posted delivery,
quest-gated recipes, permanently learned recipes, a notice board, a shop loop, and a
tiny town lane. The HUD tracker is useful in the moment, but it is too small to carry
the next few slices by itself. Marigold needs a simple place to check:

- what quests are active or ready;
- which quests are already complete;
- what item and quantity each open quest needs;
- which recipes she knows;
- what ingredients each recipe needs;
- how many of each ingredient she is carrying;
- whether a recipe can be brewed right now.

This is not a full journal milestone. It is a small readability slice for the current
systems.

## Why This Comes Next

Vertical Slice 1.0 proved a small town/request loop. Adding more quests immediately would
make the game harder to read unless the player has a better way to review what they are
doing. A notebook is the smallest UI step that supports more authored quest chains while
still respecting the "one beautiful, tiny, working loop" strategy.

## Player Flow

1. Press the notebook input, suggested `J`.
2. The notebook opens over gameplay and pauses movement/interaction like the cauldron UI.
3. The `Quests` tab shows active and ready quests first.
4. The player can also see completed quests in a compact history section.
5. Selecting or highlighting a quest shows the requester, needed item, needed quantity,
   current inventory count, and a short objective.
6. Switch to the `Recipes` tab.
7. Known recipes are listed: Calming Tea by default, plus Root-Wake Tonic and Glowberry
   Cordial after they are learned.
8. Active quest recipes that are temporarily exposed should also appear while their quest
   is active or ready.
9. Selecting a recipe shows its ingredients, owned counts, output, and whether it can be
   brewed now.
10. Press the notebook input or `Esc` to close and resume play.

## Required Scope

### Notebook UI

- Add one compact UI scene: `scenes/ui/NotebookPanel.tscn`.
- Add one script: `scripts/ui/NotebookPanel.gd`.
- Register it as an autoload UI scene in `project.godot`, similar to `InventoryPanel` and
  `CauldronCraftingPanel`.
- Add one input action, suggested name: `toggle_notebook`.
- Default binding suggestion: `J`.
- The notebook should be readable at the 640x360 internal resolution.
- Use the current warm dark panel style already used by HUD/dialogue/inventory.
- It can be modal. If modal, player movement and interaction should pause while it is
  active.
- It should close on `toggle_notebook` or `ui_cancel`.
- Do not make a decorative full-screen book spread yet. Keep it compact and functional.

### Tabs

- Add two simple tabs or tab-like buttons:
  - `Quests`
  - `Recipes`
- Default tab: `Quests`.
- The tabs can be implemented with Godot `TabContainer`, buttons, or a small local
  control pattern. Prefer the simplest option that is readable and stable.

### Quest Notes

- Source data from `QuestDatabase`, `QuestSystem`, `Inventory`, `ItemDatabase`, and
  `RecipeDatabase`.
- Show open quests first:
  - `active`
  - `ready_to_turn_in`
- Show completed quests below, either collapsed by default or in a short lower section.
- Do not show locked/not-started quests yet, except possibly a small "No open quests"
  empty state.
- For each open quest, show:
  - title;
  - NPC/requester name;
  - state label such as `In progress` or `Ready`;
  - turn-in item name;
  - current/needed quantity, such as `Glowberry Cordial 1/2`;
  - compact objective text.
- For completed quests, title and requester are enough for this slice.
- It is acceptable to reuse or mirror the existing HUD objective wording, but the
  notebook should show quantities clearly for multi-item turn-ins.
- Do not add quest descriptions, maps, portraits, branching objectives, deadlines, or
  categories.

### Recipe Notes

- Source data from `RecipeDatabase`, `RecipeKnowledgeSystem`, `QuestSystem`,
  `Inventory`, and `ItemDatabase`.
- Show recipes that are known by default or permanently learned.
- Also show quest-gated recipes while their quest is active or ready.
- Do not show unknown future recipes.
- For each recipe, show:
  - recipe name;
  - station, currently `cauldron`;
  - output item and output quantity;
  - ingredient names;
  - owned/needed counts;
  - a simple status such as `Ready` or `Missing ingredients`.
- Recipe order can be simple and deterministic: recipe names alphabetically, or current
  database order if that is easier.
- Do not add recipe discovery, quality, traits, crafting from the notebook, favorites,
  search, categories, or filters.

### Input and Pausing

- Add `toggle_notebook` to `project.godot`.
- While the notebook is open:
  - movement should pause;
  - interact should not trigger world objects;
  - dialogue and cauldron UI should continue to take priority if already open.
- If possible, add a tiny public helper:

```gdscript
NotebookPanel.is_active() -> bool
```

- Update `PlayerController.gd` only as much as needed to respect `NotebookPanel.is_active()`.

### Save/Load

- No new save data should be needed.
- The notebook should rebuild from existing singleton state whenever it opens.
- It should react correctly after save/load because quest states, known recipes,
  inventory, and gold already persist.

## Suggested Files

```text
docs/plans/vertical_slice_1_1_notebook_notes.md
project.godot
scenes/ui/NotebookPanel.tscn
scripts/ui/NotebookPanel.gd
scripts/player/PlayerController.gd
tools/verify_vertical_slice_1_1.gd
docs/PROGRESS.md
```

Existing systems to reuse:

```text
QuestDatabase
QuestSystem
RecipeDatabase
RecipeKnowledgeSystem
Inventory
ItemDatabase
HUD._quest_objective_text() as a reference, not necessarily a dependency
InventoryPanel.gd as a simple UI/rebuild pattern reference
CauldronCraftingPanel.gd as a modal input reference
```

## Implementation Order

1. Run focused 0.6, 0.7, 0.8, 0.9, and 1.0 verifiers before editing.
2. Inspect `InventoryPanel.gd`, `CauldronCraftingPanel.gd`, `HUD.gd`,
   `PlayerController.gd`, `project.godot`, `QuestSystem.gd`, and `RecipeKnowledgeSystem.gd`.
3. Add `toggle_notebook` input.
4. Add `NotebookPanel.tscn` with compact warm styling and Quests/Recipes views.
5. Implement `NotebookPanel.gd` as a rebuild-on-open UI.
6. Add helper functions for quest row text, recipe visibility, ingredient progress, and
   ready/missing status.
7. Update `PlayerController.gd` to pause movement and interaction while the notebook is
   active.
8. Add `tools/verify_vertical_slice_1_1.gd`.
9. Run 0.6, 0.7, 0.8, 0.9, 1.0, and 1.1 focused verifiers.
10. Update `docs/PROGRESS.md` and this plan with implementation notes.

## Verification

Add `tools/verify_vertical_slice_1_1.gd`.

The verifier should check:

- `NotebookPanel.tscn` exists and loads.
- `project.godot` includes the `toggle_notebook` input action.
- The notebook autoload exists.
- `NotebookPanel.is_active()` reports open/closed state.
- Active quests are shown.
- Ready quests are shown before or alongside active quests.
- Completed quests are shown in the completed/history section.
- Multi-item quest progress displays the current and needed count, especially
  `Glowberry Cordial 0/2` or `2/2` for `camellia_cordial_delivery`.
- Known recipes are shown.
- `calming_tea` is shown by default.
- `glowberry_cordial` is hidden before it is learned or quest-active.
- `glowberry_cordial` is shown after `RecipeKnowledgeSystem.unlock_recipe()`.
- Quest-active recipes are shown while their quest is active or ready.
- Ingredient owned/needed counts update from `Inventory`.
- Recipe ready/missing status updates after ingredients are added.
- The notebook can close cleanly.
- Existing 0.6-1.0 verifiers still pass.

## Manual Acceptance Test

1. Start or continue a game.
2. Press `J` and confirm the notebook opens.
3. Confirm movement and world interaction pause while the notebook is open.
4. Start Sage's request and open the notebook.
5. Confirm `A Little Root Trouble` appears with Root-Wake Tonic progress.
6. Gather/craft until the quest is ready and confirm the notebook updates to ready.
7. Complete Sage and Camellia's first request, then check the completed section.
8. Confirm learned recipes appear in the recipe tab.
9. Start `A Cordial Delivery` from the Mapleton Lane notice board.
10. Confirm the quest tab shows `Glowberry Cordial 0/2`, then `1/2`, then ready at `2/2`.
11. Confirm the recipe tab shows Glowberry Cordial ingredients and ready/missing status.
12. Close the notebook with `J` and `Esc`.
13. Sleep/save/continue and confirm the notebook still reflects saved quest/recipe state.

## Non-Goals

- New quests.
- New recipes.
- New items.
- New NPCs.
- New areas.
- Full quest journal.
- Quest map markers, compass arrows, or world pins.
- NPC portraits or relationship info.
- Calendar, seasons, deadlines, or timed request UI.
- Recipe discovery, recipe categories, favorites, search, or filters.
- Crafting directly from the notebook.
- Item quality, traits, star ratings, or advanced Atelier-style item details.
- Redesigning the HUD, inventory panel, or cauldron UI.

## Risks

- The notebook can easily become a full journal. Keep it read-only, compact, and focused
  on current quests plus known recipes.
- A 640x360 UI can become cramped. Prefer short text, stable row heights, and clear
  selected-detail areas over trying to show everything at once.
- Avoid duplicating too much quest-objective logic. Small duplication is acceptable for
  clearer multi-item quantities, but do not create a broad objective framework yet.
- Modal input should not conflict with DialogueBox or CauldronCraftingPanel.

## Success Criteria

- The player can check current quest requirements without relying only on memory or the
  tiny HUD tracker.
- The player can check known recipes and ingredient counts away from the cauldron.
- Multi-item delivery progress is clear.
- The notebook reads from existing data and save state.
- Existing 0.6-1.0 loops remain intact.
