-- Last Route: Stage 1 map generator
-- Run this entire script ONCE in Roblox Studio's Command Bar while NOT in Play mode.
-- It creates only the 100-station underground map, tunnels, rails, sleepers, lights, and end wall.
-- It does NOT create the train, loot, inventory, weapons, or zombies.

local Workspace = game:GetService("Workspace")

local CONFIG = {
    MAP_NAME = "LastRouteMap",
    REBUILD_EXISTING = false, -- Change to true only if you intentionally want to delete/rebuild this map.
    STATION_COUNT = 100,
    STATION_SPACING = 300,
    STATION_LENGTH = 140,
    STATION_WIDTH = 64,
    TUNNEL_LENGTH = 160,
    TUNNEL_WIDTH = 36,
    FLOOR_Y = -80,
    FLOOR_THICKNESS = 8,
    WALL_HEIGHT = 36,
    WALL_THICKNESS = 2,
    ROOF_THICKNESS = 4,
    RAIL_GAUGE = 6,
    SLEEPER_SPACING = 8,
    LIGHT_RANGE = 32,
    LIGHT_BRIGHTNESS = 1.25,
}

local existing = Workspace:FindFirstChild(CONFIG.MAP_NAME)
if existing then
    if not CONFIG.REBUILD_EXISTING then
        warn("[Last Route] Workspace." .. CONFIG.MAP_NAME .. " already exists. Nothing was changed. If you intentionally want to rebuild it, set REBUILD_EXISTING = true and run again.")
        return
    end
    existing:Destroy()
end

local map = Instance.new("Folder")
map.Name = CONFIG.MAP_NAME
map:SetAttribute("Stage", 1)
map:SetAttribute("StationCount", CONFIG.STATION_COUNT)
map:SetAttribute("GeneratedBy", "LastRouteMapGenerator")
map.Parent = Workspace

local stationsFolder = Instance.new("Folder")
stationsFolder.Name = "Stations"
stationsFolder.Parent = map

local tunnelsFolder = Instance.new("Folder")
tunnelsFolder.Name = "TunnelSegments"
tunnelsFolder.Parent = map

local trackFolder = Instance.new("Folder")
trackFolder.Name = "Track"
trackFolder.Parent = map

local lightingFolder = Instance.new("Folder")
lightingFolder.Name = "Lighting"
lightingFolder.Parent = map

local endFolder = Instance.new("Folder")
endFolder.Name = "EndArea"
endFolder.Parent = map

local C = {
    Concrete = Color3.fromRGB(69, 72, 76),
    DarkConcrete = Color3.fromRGB(43, 46, 50),
    Platform = Color3.fromRGB(105, 107, 108),
    Edge = Color3.fromRGB(218, 181, 72),
    Metal = Color3.fromRGB(73, 78, 83),
    Rail = Color3.fromRGB(125, 131, 137),
    Sleeper = Color3.fromRGB(64, 53, 46),
    Sign = Color3.fromRGB(29, 39, 47),
    Text = Color3.fromRGB(235, 235, 226),
    Light = Color3.fromRGB(235, 219, 168),
    End = Color3.fromRGB(30, 32, 35),
}

local function makePart(parent, name, size, position, material, color, canCollide)
    local part = Instance.new("Part")
    part.Name = name
    part.Size = size
    part.Position = position
    part.Anchored = true
    part.Material = material or Enum.Material.Concrete
    part.Color = color or C.Concrete
    part.TopSurface = Enum.SurfaceType.Smooth
    part.BottomSurface = Enum.SurfaceType.Smooth
    part.CanCollide = (canCollide ~= false)
    part.CastShadow = true
    part.Parent = parent
    return part
end

local function makeLight(parent, x, z)
    local fixture = makePart(
        parent,
        "CeilingLight",
        Vector3.new(3, 0.45, 2),
        Vector3.new(x, CONFIG.FLOOR_Y + CONFIG.WALL_HEIGHT - 1.1, z),
        Enum.Material.Metal,
        C.Metal,
        false
    )
    local light = Instance.new("PointLight")
    light.Name = "StationLight"
    light.Color = C.Light
    light.Range = CONFIG.LIGHT_RANGE
    light.Brightness = CONFIG.LIGHT_BRIGHTNESS
    light.Shadows = false
    light.Parent = fixture
end

local function makeSign(parent, stationNumber, x, z)
    local sign = makePart(
        parent,
        "StationSign_" .. string.format("%03d", stationNumber),
        Vector3.new(16, 4, 0.6),
        Vector3.new(x, CONFIG.FLOOR_Y + 25, z),
        Enum.Material.Metal,
        C.Sign,
        false
    )
    sign:SetAttribute("StationNumber", stationNumber)

    for _, face in ipairs({Enum.NormalId.Front, Enum.NormalId.Back}) do
        local gui = Instance.new("SurfaceGui")
        gui.Name = "StationNumberGui"
        gui.Face = face
        gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
        gui.PixelsPerStud = 30
        gui.Parent = sign

        local label = Instance.new("TextLabel")
        label.Name = "Number"
        label.Size = UDim2.fromScale(1, 1)
        label.BackgroundTransparency = 1
        label.Text = "STATION " .. string.format("%03d", stationNumber)
        label.TextColor3 = C.Text
        label.TextScaled = true
        label.Font = Enum.Font.GothamBold
        label.Parent = gui
    end
end

local function makeTrackSegment(parent, startX, length)
    local centerX = startX + length / 2
    local railY = CONFIG.FLOOR_Y + CONFIG.FLOOR_THICKNESS / 2 + 0.9
    local sleeperY = CONFIG.FLOOR_Y + CONFIG.FLOOR_THICKNESS / 2 + 0.25

    for _, z in ipairs({-CONFIG.RAIL_GAUGE / 2, CONFIG.RAIL_GAUGE / 2}) do
        makePart(
            parent,
            "Rail",
            Vector3.new(length, 0.8, 0.8),
            Vector3.new(centerX, railY, z),
            Enum.Material.Metal,
            C.Rail,
            true
        )
    end

    local x = startX + CONFIG.SLEEPER_SPACING / 2
    local endX = startX + length
    local sleeperCount = 0
    while x < endX do
        makePart(
            parent,
            "Sleeper",
            Vector3.new(4.5, 0.5, 10),
            Vector3.new(x, sleeperY, 0),
            Enum.Material.Wood,
            C.Sleeper,
            true
        )
        sleeperCount += 1
        x += CONFIG.SLEEPER_SPACING
        if sleeperCount % 250 == 0 then
            task.wait()
        end
    end
end

local function buildStation(stationNumber)
    local centerX = (stationNumber - 1) * CONFIG.STATION_SPACING
    local halfLength = CONFIG.STATION_LENGTH / 2
    local halfWidth = CONFIG.STATION_WIDTH / 2
    local floorTop = CONFIG.FLOOR_Y + CONFIG.FLOOR_THICKNESS / 2
    local ceilingY = CONFIG.FLOOR_Y + CONFIG.WALL_HEIGHT
    local station = Instance.new("Model")
    station.Name = "Station_" .. string.format("%03d", stationNumber)
    station:SetAttribute("StationNumber", stationNumber)
    station:SetAttribute("IsRepairStation", stationNumber % 5 == 0)
    station:SetAttribute("RouteDistance", (stationNumber - 1) * CONFIG.STATION_SPACING)
    station.Parent = stationsFolder

    makePart(station, "StationFloor",
        Vector3.new(CONFIG.STATION_LENGTH, CONFIG.FLOOR_THICKNESS, CONFIG.STATION_WIDTH),
        Vector3.new(centerX, CONFIG.FLOOR_Y, 0), Enum.Material.Concrete, C.Concrete)

    makePart(station, "Ceiling",
        Vector3.new(CONFIG.STATION_LENGTH, CONFIG.ROOF_THICKNESS, CONFIG.STATION_WIDTH),
        Vector3.new(centerX, ceilingY + CONFIG.ROOF_THICKNESS / 2, 0),
        Enum.Material.Concrete, C.DarkConcrete)

    for _, z in ipairs({-halfWidth, halfWidth}) do
        makePart(station, "SideWall",
            Vector3.new(CONFIG.STATION_LENGTH, CONFIG.WALL_HEIGHT, CONFIG.WALL_THICKNESS),
            Vector3.new(centerX, CONFIG.FLOOR_Y + CONFIG.WALL_HEIGHT / 2, z),
            Enum.Material.Concrete, C.DarkConcrete)
    end

    -- Two raised platforms flank the track, leaving the middle clear for a future train.
    for _, side in ipairs({-1, 1}) do
        local platformZ = side * 13
        makePart(station, "PassengerPlatform",
            Vector3.new(CONFIG.STATION_LENGTH - 8, 2, 12),
            Vector3.new(centerX, floorTop + 1, platformZ),
            Enum.Material.Concrete, C.Platform)

        local edgeZ = side * 7
        makePart(station, "PlatformSafetyEdge",
            Vector3.new(CONFIG.STATION_LENGTH - 8, 0.18, 0.7),
            Vector3.new(centerX, floorTop + 2.09, edgeZ),
            Enum.Material.SmoothPlastic, C.Edge, false)

        -- Repeating structural columns along both platform edges.
        for offset = -48, 48, 24 do
            makePart(station, "SupportColumn",
                Vector3.new(2.2, CONFIG.WALL_HEIGHT - 2, 2.2),
                Vector3.new(centerX + offset, CONFIG.FLOOR_Y + (CONFIG.WALL_HEIGHT - 2) / 2, side * 28),
                Enum.Material.Concrete, C.Metal)
        end
    end

    makeSign(station, stationNumber, centerX, -20)
    makeSign(station, stationNumber, centerX, 20)
    makeLight(lightingFolder, centerX - 35, 0)
    makeLight(lightingFolder, centerX + 35, 0)

    makeTrackSegment(trackFolder, centerX - halfLength, CONFIG.STATION_LENGTH)
end

local function buildTunnel(tunnelNumber)
    local stationCenterX = (tunnelNumber - 1) * CONFIG.STATION_SPACING
    local startX = stationCenterX + CONFIG.STATION_LENGTH / 2
    local nextStationStartX = tunnelNumber * CONFIG.STATION_SPACING - CONFIG.STATION_LENGTH / 2
    local length = nextStationStartX - startX
    local centerX = startX + length / 2
    local halfWidth = CONFIG.TUNNEL_WIDTH / 2
    local floorTop = CONFIG.FLOOR_Y + CONFIG.FLOOR_THICKNESS / 2
    local ceilingY = CONFIG.FLOOR_Y + CONFIG.WALL_HEIGHT

    local tunnel = Instance.new("Model")
    tunnel.Name = "Tunnel_" .. string.format("%03d_to_%03d", tunnelNumber, tunnelNumber + 1)
    tunnel:SetAttribute("FromStation", tunnelNumber)
    tunnel:SetAttribute("ToStation", tunnelNumber + 1)
    tunnel.Parent = tunnelsFolder

    makePart(tunnel, "TunnelFloor",
        Vector3.new(length, CONFIG.FLOOR_THICKNESS, CONFIG.TUNNEL_WIDTH),
        Vector3.new(centerX, CONFIG.FLOOR_Y, 0), Enum.Material.Concrete, C.Concrete)

    makePart(tunnel, "TunnelRoof",
        Vector3.new(length, CONFIG.ROOF_THICKNESS, CONFIG.TUNNEL_WIDTH),
        Vector3.new(centerX, ceilingY + CONFIG.ROOF_THICKNESS / 2, 0),
        Enum.Material.Concrete, C.DarkConcrete)

    for _, z in ipairs({-halfWidth, halfWidth}) do
        makePart(tunnel, "TunnelWall",
            Vector3.new(length, CONFIG.WALL_HEIGHT, CONFIG.WALL_THICKNESS),
            Vector3.new(centerX, CONFIG.FLOOR_Y + CONFIG.WALL_HEIGHT / 2, z),
            Enum.Material.Concrete, C.DarkConcrete)
    end

    -- Tunnel ribs reinforce the structure visually without creating thousands of tiny parts.
    for offset = -length / 2 + 20, length / 2 - 20, 40 do
        for _, z in ipairs({-halfWidth + 2, halfWidth - 2}) do
            makePart(tunnel, "TunnelRib",
                Vector3.new(1.5, CONFIG.WALL_HEIGHT, 1.5),
                Vector3.new(centerX + offset, CONFIG.FLOOR_Y + CONFIG.WALL_HEIGHT / 2, z),
                Enum.Material.Metal, C.Metal, false)
        end
    end

    makeLight(lightingFolder, centerX - 35, 0)
    makeLight(lightingFolder, centerX + 35, 0)
    makeTrackSegment(trackFolder, startX, length)
end

print("[Last Route] Building " .. CONFIG.STATION_COUNT .. " underground stations...")
for stationNumber = 1, CONFIG.STATION_COUNT do
    buildStation(stationNumber)
    if stationNumber < CONFIG.STATION_COUNT then
        buildTunnel(stationNumber)
    end
    if stationNumber % 5 == 0 then
        print("[Last Route] Built through station " .. stationNumber .. "/" .. CONFIG.STATION_COUNT)
        task.wait()
    end
end

-- Final wall after station 100; no ending scene or military NPCs in Stage 1.
local finalX = (CONFIG.STATION_COUNT - 1) * CONFIG.STATION_SPACING + CONFIG.STATION_LENGTH / 2 + 8
makePart(endFolder, "FinalEndWall",
    Vector3.new(4, CONFIG.WALL_HEIGHT, CONFIG.TUNNEL_WIDTH + 8),
    Vector3.new(finalX, CONFIG.FLOOR_Y + CONFIG.WALL_HEIGHT / 2, 0),
    Enum.Material.Concrete, C.End)

local endSign = makePart(endFolder, "EndOfRouteSign",
    Vector3.new(12, 3, 0.5),
    Vector3.new(finalX - 3, CONFIG.FLOOR_Y + 18, 0),
    Enum.Material.Metal, C.Sign, false)
local gui = Instance.new("SurfaceGui")
gui.Face = Enum.NormalId.Front
gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
gui.PixelsPerStud = 30
gui.Parent = endSign
local label = Instance.new("TextLabel")
label.Size = UDim2.fromScale(1, 1)
label.BackgroundTransparency = 1
label.Text = "END OF ROUTE"
label.TextColor3 = C.Text
label.TextScaled = true
label.Font = Enum.Font.GothamBold
label.Parent = gui

map:SetAttribute("GenerationComplete", true)
map:SetAttribute("LastStationNumber", CONFIG.STATION_COUNT)

print("[Last Route] STAGE 1 MAP GENERATED.")
print("[Last Route] Stations: " .. #stationsFolder:GetChildren())
print("[Last Route] Tunnels: " .. #tunnelsFolder:GetChildren())
print("[Last Route] Track segments: " .. #trackFolder:GetChildren())
print("[Last Route] IMPORTANT: Save the place with File > Save to File or Publish to Roblox.")
