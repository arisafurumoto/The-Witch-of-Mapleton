# Vertical Slice 1.2 - Sage's Posted Delivery and Lane Presence v1

> Status: IMPLEMENTED and headless-verified.
> Implemented 2026-06-28.

## Goal

Add one more tiny authored town request so the game proves that the Mapleton Lane,
notice board, notebook, crafting, and direct-delivery loop can support a short quest
chain beyond Camellia.

This should not become a town system. The slice should add exactly one new posted
delivery, one static Sage lane presence, and the smallest notice-board change needed to
surface authored requests in sequence.

## Why This Comes Next

Vertical Slice 1.0 introduced a direct posted delivery. Vertical Slice 1.1 made active
quests and known recipes readable. The next useful proof is a second board-driven
delivery that reuses those systems without adding new content categories.

This creates the first concrete need for the notice board to know about more than one
authored request, but it still does not justify a request-board menu, repeatable
requests, deadlines, reputation, schedules, or a full village.

## Player Flow

1. Complete `camellia_cordial_delivery`.
2. Sleep to Day 4.
3. Leave the shop exterior for Mapleton Lane.
4. Read the notice board.
5. Accept Sage's new posted request.
6. Open the notebook and confirm the quest appears with Root-Wake Tonic progress.
7. Gather Dewcap Mushroom and Glowberry if needed.
8. Brew Root-Wake Tonic at the cauldron.
9. Return to Mapleton Lane.
10. Talk to Sage at his small plant stall.
11. Turn in Root-Wake Tonic.
12. Receive gold.
13. Sleep/save/continue and confirm the completed quest persists.

## Required Scope

### New Quest Data

Add one quest to `data/quests.json`.

Suggested id:

```text
sage_seedling_restock
```

Suggested content:

- Title: `A Gentle Restock`
- NPC: `Sage`
- Turn-in: `root_wake_tonic` x1
- Reward: 45 gold
- Required quest: `camellia_cordial_delivery`
- Minimum day: 4
- Reward items: none
- Reward recipes: none

This uses existing items, recipes, ingredients, and recipe knowledge. Do not add a new
recipe, ingredient, or seed/farming mechanic.

### Mapleton Lane Sage

- Add Sage to `MapletonLane.tscn` near a simple placeholder plant stall.
- Use existing Sage walking/idle art from `art/characters/npcs/sage/Sage.tres`.
- Keep him static for this slice; no schedules, pathing, shop interior, or plant shop.
- Add a small interaction script for his lane delivery behavior.
- It is acceptable to mirror `CamelliaLaneNPC.gd` for now. Create a shared delivery NPC
  script only if the implementation becomes simpler and clearer than duplication.

### Notice Board

- Extend the current one-request `NoticeBoard.gd` into a tiny authored-sequence board.
- Suggested export:

```gdscript
@export var quest_ids: PackedStringArray = PackedStringArray([
	"camellia_cordial_delivery",
	"sage_seedling_restock",
])
```

- Keep compatibility with the current `quest_id` export if it is still useful for old
  scene wiring or verifier expectations.
- Board behavior should be deterministic:
  - show active/ready request text first;
  - otherwise start the first available request in list order;
  - otherwise show a simple no-request message;
  - completed requests should not restart.
- Do not build a board menu, list UI, filters, repeatable jobs, random requests,
  deadlines, request expiry, reputation, or mailbox turn-ins.

### Notebook and HUD

- Rely on the existing notebook to show the new quest and Root-Wake Tonic progress.
- The HUD tracker can continue using the existing single tracked quest behavior.
- Do not redesign the notebook or HUD for this slice.

### Save/Load

- No new save fields should be needed.
- The new quest should persist through existing `QuestSystem` save data.
- Mapleton Lane can remain the saved scene if the player saves there.

## Suggested Files

```text
docs/plans/vertical_slice_1_2_sage_posted_delivery.md
data/quests.json
scripts/core/NoticeBoard.gd
scripts/npc/SageLaneNPC.gd
scenes/world/MapletonLane.tscn
tools/verify_vertical_slice_1_2.gd
docs/PROGRESS.md
```

Optional only if the implementation clearly benefits:

```text
scripts/npc/LaneDeliveryNPC.gd
```

## Implementation Order

1. Run focused 0.6, 0.7, 0.8, 0.9, 1.0, and 1.1 verifiers before editing.
2. Inspect `NoticeBoard.gd`, `CamelliaLaneNPC.gd`, `SageNPC.gd`, `MapletonLane.tscn`,
   `QuestSystem.gd`, and the notebook verifier.
3. Add `sage_seedling_restock` to `data/quests.json`.
4. Extend `NoticeBoard.gd` to support a small ordered quest list.
5. Add a placeholder Sage plant stall and Sage lane NPC to `MapletonLane.tscn`.
6. Add the smallest lane interaction script for Sage's request.
7. Add `tools/verify_vertical_slice_1_2.gd`.
8. Run 0.6-1.2 focused verifiers.
9. Update `docs/PROGRESS.md` and this plan with implementation notes.

## Verification

Added `tools/verify_vertical_slice_1_2.gd`.

The verifier checks:

- `QuestDatabase` loads `sage_seedling_restock`.
- The quest requires `camellia_cordial_delivery`.
- The quest is unavailable before Camellia's delivery is complete.
- The quest is unavailable before Day 4.
- `MapletonLane.tscn` includes Sage and his plant stall placeholder.
- Sage uses the existing Sage sprite frames.
- The notice board can still start `camellia_cordial_delivery`.
- After Camellia delivery is completed and Day 4 begins, the notice board starts
  `sage_seedling_restock`.
- Adding `root_wake_tonic` x1 moves the new quest to ready.
- Talking to lane Sage completes the quest, consumes exactly one tonic, and awards the
  configured gold.
- The notebook shows the new active/ready/completed quest using existing behavior.
- The completed quest survives `QuestSystem.get_save_data()` / `load_from()`.
- Existing 0.6-1.1 verifiers still pass.

## Implementation Notes

- Added `sage_seedling_restock` to `data/quests.json`; it requires
  `camellia_cordial_delivery`, starts on Day 4, consumes `root_wake_tonic` x1, and
  rewards 45 gold.
- Extended `scripts/core/NoticeBoard.gd` with an optional ordered `quest_ids` list while
  preserving the original `quest_id` export for compatibility.
- Added a placeholder plant stall and static Sage to `scenes/world/MapletonLane.tscn`.
- Added `scripts/npc/SageLaneNPC.gd` for the in-person turn-in interaction.
- Added `tools/verify_vertical_slice_1_2.gd`; it passes headlessly.

## Manual Acceptance Test

1. Start from a save where `camellia_cordial_delivery` is complete, or complete it
   manually.
2. Sleep to Day 4.
3. Go to Mapleton Lane and read the notice board.
4. Confirm Sage's request starts.
5. Open the notebook with `J` and confirm `A Gentle Restock` shows Root-Wake Tonic
   progress.
6. Brew one Root-Wake Tonic.
7. Return to Mapleton Lane and talk to Sage at the plant stall.
8. Confirm the tonic is removed, gold increases by 45, and the quest completes.
9. Sleep/save/continue and confirm the quest remains completed.
10. Confirm Camellia's lane dialogue and the earlier shop/customer loops still work.

## Non-Goals

- New items.
- New recipes.
- New gathering nodes.
- Farming or using Moonleaf Seed Packet.
- Plant shop interior.
- Sage schedule.
- Full village map.
- New village NPCs.
- Notice-board menu/list UI.
- Repeatable/procedural requests.
- Mailbox turn-ins.
- Reputation, relationship points, deadlines, quality ratings, or request penalties.
- Redesigning the notebook, HUD, cauldron UI, or shop loop.

## Risks

- The notice board can easily become a request-management system. Keep it an authored
  sequence only.
- Adding Sage to Mapleton Lane can tempt a plant-shop system. Keep the stall decorative
  and the interaction quest-only.
- Reusing Root-Wake Tonic could feel repetitive. For this slice that is acceptable
  because the point is proving the second delivery loop without adding new content.
- Duplicating lane NPC delivery logic may be slightly inelegant. Prefer the simple
  duplicate script unless a tiny shared script is genuinely clearer.

## Success Criteria

- The player can complete a second posted delivery after Camellia.
- The notice board supports a tiny authored sequence without becoming a menu.
- The notebook makes the new request readable without extra UI work.
- Existing save/load, crafting, lane transition, Saffron follow, and shop loops remain
  intact.
