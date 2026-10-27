# Last Route — Stage 1: Map

## Status
Implementation script prepared; it has not yet been run inside Roblox Studio, so the generated map is not yet Studio-tested.

## Scope
- 100 underground stations in sequential order.
- 99 connecting tunnel sections.
- Connected rails and sleepers through station and tunnel sections.
- Station floors, raised side platforms, safety edges, support columns, signs, and lights.
- Final wall beyond station 100.
- No train, loot, inventory, weapons, or zombies.

## Run in Roblox Studio
1. Open the existing Last Route place.
2. Open **View → Command Bar**.
3. Make sure Studio is **not** in Play mode.
4. Open `tools/LastRouteMapGenerator.lua` from this repository, copy the entire file into the Command Bar, and press Enter.
5. Wait for the Output window to print `STAGE 1 MAP GENERATED`.
6. Inspect the Workspace folder `LastRouteMap`, then use **File → Save to File** to save a local `.rbxl` / `.rbxlx` place, or publish/save the existing place as appropriate.

The script intentionally stops if `Workspace.LastRouteMap` already exists. To intentionally regenerate, change `REBUILD_EXISTING = false` to `true` near the top first. This deletes only the generated `LastRouteMap` folder, not the rest of Workspace.

## Important limitations
- This is a procedural blockout / first-pass environment, not final art.
- The map is placed underground at Y=-80 so a default surface Baseplate does not cover the route.
- The route is long (100 stations); test performance in Studio and refine visuals after verifying layout.
- The script must be run in Studio Edit mode from the Command Bar to persist the generated Parts into the place. Running it only during Play mode will not preserve the generated map after stopping.
- No claim is made that this script has been executed or tested in Studio yet.
