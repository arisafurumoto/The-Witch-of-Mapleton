# Vertical Slice 0.2 - Sage's First Village Request

> Status: IN PROGRESS.
> First implementation pass is in-game. Keep remaining work small and focused.

## Goal

Prove the next long-term spine of the game: **quest-driven crafting progression**.

Vertical Slice 0.2 should show that Marigold can receive a non-shop request from a
villager, gather ingredients, craft a requested item, turn it in, receive a reward,
and save the completed quest state.

This slice should stay small and build directly on the existing shop/forest/crafting
loop. It should not introduce the full village, farming, shop management, romance,
relationship systems, or a quest journal yet.

## Player Flow

1. Player starts a new game in Marigold's shop.
2. Sage is already visiting the shop.
3. Sage introduces himself as the plant shop owner and asks for help with a plant tonic.
4. Player accepts the quest.
5. Player gathers Moonleaf x2 and Forest Water x1 from the existing forest clearing.
6. Player returns to the shop.
7. Player crafts Root-Wake Tonic at a small potting bench or workbench.
8. Player talks to Sage again and gives him the tonic.
9. Sage thanks Marigold, rewards her, and leaves.
10. Quest completion is saved.
11. Player sleeps; the quest remains completed after reload.

## Quest Details

Quest ID: `sage_first_request`

Quest title: **A Little Root Trouble**

Quest NPC: **Sage**

Sage source: `ideas/ideas.md`

Sage direction:

- Plant shop owner.
- Warm, kind, gentle, and quietly observant.
- Knowledgeable about plants and future farming advice.
- Elf with silver hair that falls slightly into his eyes.
- Wears oversized soft linen button-downs with rolled sleeves and a heavy canvas
  foraging apron.
- Backstory: he ran away from suffocating traditional family expectations to touch
  dirt, grow messy things, and figure out who he actually is.

Suggested quest premise:

Sage has a tray of young roots that will not wake up after being moved. He has the
plant knowledge, but asks Marigold to try a little witchcraft. This frames Marigold as
useful to Mapleton without turning the request into shop commerce.

Suggested dialogue tone:

- Gentle and observant.
- Slightly self-conscious but sincere.
- Plant-focused, with warmth rather than drama.
- No romance route content yet.

Example intent, not final dialogue:

- Sage politely interrupts Marigold's first morning in the shop.
- He asks whether she can make something mild enough for fragile roots.
- On completion, he gives her a seed packet and says she may have a good hand for
  green things.

## Required Content

Items:

- `root_wake_tonic`
  - Category: `crafted_good`
  - Tags: `plant`, `tonic`, `quest`, `sage`
  - Purpose: quest turn-in item.
- `moonleaf_seed_packet`
  - Category: `seed` or `quest_item`
  - Tags: `seed`, `moonleaf`, `future_farming`
  - Purpose: reward and future farming hook only; it is not usable in 0.2.

Recipe:

- `root_wake_tonic`
  - Station: `potting_bench`
  - Ingredients: Moonleaf x2, Forest Water x1
  - Output: Root-Wake Tonic x1

Reward:

- 25 gold.
- Moonleaf Seed Packet x1.
- Quest state becomes completed.

## Required Systems

Add a minimal quest system only:

- `data/quests.json`
- `QuestDatabase.gd`
- `QuestSystem.gd`
- `QuestSystem` autoload before `SaveSystem`
- Save/load support for quest state.

Quest states:

```text
not_started
active
ready_to_turn_in
completed
```

Minimum quest API:

```gdscript
get_quest_state(quest_id: String) -> String
start_quest(quest_id: String) -> void
can_turn_in(quest_id: String) -> bool
complete_quest(quest_id: String) -> bool
get_save_data() -> Dictionary
load_from(data: Dictionary) -> void
```

Sage interaction behavior:

- If the quest is not started and the start condition is met, Sage starts the quest.
- If the quest is active and Marigold lacks Root-Wake Tonic, Sage gives reminder dialogue.
- If Marigold has Root-Wake Tonic, Sage removes it, gives the reward, completes the
  quest, and leaves.
- If the quest is completed, Sage should not reappear for this slice.

Start condition:

- Day 1 or later.
- No first-sale requirement. This slice starts with a villager request because the 0.1
  shop customer only appears after their requested item already exists.

Crafting:

- Add a small potting bench or workbench interactable in the shop.
- Reuse the existing `CraftingStation.gd` pattern if possible by setting
  `recipe_id = "root_wake_tonic"`.
- Keep the existing cauldron as the Calming Tea station.
- Do not build a recipe selection UI in 0.2.

## Save/Load Notes

Save file should add a `quests` dictionary while old saves remain safe.

Example future save shape:

```json
{
  "quests": {
    "sage_first_request": "completed"
  }
}
```

Old saves without `quests` should load as if all quests are `not_started`.

Quest completion must persist after:

- Sleeping.
- Returning to the title menu and continuing.
- Relaunching the game.

## Explicit Non-Goals

Do not add:

- Full village map.
- Plant shop scene.
- Farming.
- Seed planting.
- Quest journal UI.
- Quest markers.
- Multiple simultaneous quests.
- NPC schedules.
- Relationship points.
- Romance content.
- Sage final art.
- Shop display/pricing/browsing system.
- Calendar UI.
- Combat, HP, stamina, or doctor rescue.
- Outfit changing.
- Saffron's long-term home-only arc.

## Manual Test Plan

1. Start a new game.
2. Confirm Sage appears in the shop on day 1.
3. Talk to Sage and confirm the quest starts.
4. Talk to Sage again without the tonic and confirm reminder dialogue.
5. Go to the forest and gather Moonleaf x2 and Forest Water x1.
6. Return to the shop.
7. Craft Root-Wake Tonic at the potting bench or workbench.
8. Confirm Root-Wake Tonic appears in inventory.
9. Talk to Sage.
10. Confirm Root-Wake Tonic is removed.
11. Confirm Marigold receives 25 gold and Moonleaf Seed Packet x1.
12. Confirm Sage leaves or no longer offers the quest.
13. Sleep and save.
14. Relaunch or continue from title.
15. Confirm the quest remains completed and Sage does not restart it.

Regression checks:

- First Potion Sale still works.
- Cauldron still crafts Calming Tea.
- Existing forest gatherables still refill after sleeping.
- Existing saves without quest data load safely.
- GDScript headless check prints no errors or warnings.

## Notes

- This slice should be tiny and authored.
- The seed packet is a promise of future farming, not farming itself.
- Sage is being introduced because his plant-shop identity naturally supports gathering,
  crafting, future seeds, and future farming advice.
