-- Roblox Ultra FPS Booster + Control de Brillo (Executor Version)
if not game:IsLoaded() then game.Loaded:Wait() end

local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local Terrain = Workspace:FindFirstChildOfClass("Terrain")

-- 1. Forzar propiedades ocultas de rendimiento (Si tu executor lo soporta)
local set_hidden = sethiddenproperty or set_rendering_property or function() end

pcall(function()
    settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    set_hidden(Lighting, "Technology", Enum.Technology.Compatibility)
end)

-- 2. Reducir la Luz y el Brillo de Forma Agresiva
Lighting.GlobalShadows = false
Lighting.Brightness = 0.5            -- Baja la intensidad de la luz (Por defecto suele ser 2 o más)
Lighting.ClockTime = 18             -- Cambia el cielo a un tono de atardecer/noche para quitar el sol brillante
Lighting.OutdoorAmbient = Color3.fromRGB(40, 40, 40) -- Oscurece las sombras ambientales externas
Lighting.Ambient = Color3.fromRGB(50, 50, 50)        -- Oscurece la luz ambiental interna
Lighting.ExposureCompensation = -0.5 -- Reduce la exposición global (Pantalla menos "lavada" en blanco)
Lighting.FogEnd = 9e9

-- Eliminar destellos, niebla brillante, desenfoques y rayos de sol
for _, effect in ipairs(Lighting:GetChildren()) do
    if effect:IsA("PostEffect") or effect:IsA("BloomEffect") or effect:IsA("BlurEffect") or effect:IsA("DepthOfFieldEffect") or effect:IsA("SunRaysEffect") or effect:IsA("ColorCorrectionEffect") then
        effect.Enabled = false
    end
end

-- 3. Limpiar el Terreno (Agua opaca y sin reflejos molestos)
if Terrain then
    Terrain.WaterWaveSize = 0
    Terrain.WaterWaveSpeed = 0
    Terrain.WaterReflectance = 0
    Terrain.WaterTransparency = 1
    pcall(function() set_hidden(Terrain, "Decoration", false) end)
end

-- 4. Función para remover texturas, partículas y materiales brillantes
local function potatoOptimize(obj)
    -- Elimina imágenes (Decals) y texturas repetitivas
    if obj:IsA("Decal") or obj:IsA("Texture") then
        obj:Destroy()
    -- Reemplaza materiales pesados o reflectantes por plástico liso
    elseif obj:IsA("BasePart") then
        obj.Material = Enum.Material.SmoothPlastic
        obj.Reflectance = 0
        -- Si el objeto brilla por sí mismo (Neon), le bajamos la intensidad forzada
        if obj.Material == Enum.Material.Neon then
            obj.Material = Enum.Material.SmoothPlastic
        end
        if obj:IsA("MeshPart") then
            obj.TextureID = ""
        end
    -- Apaga efectos de luz dinámicos dentro del mapa (Luces que causen lag/brillo)
    elseif obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
        obj.Brightness = obj.Brightness * 0.3 -- Atenúa las luces del mapa al 30%
    -- Apaga efectos de fuego, humo, destellos y partículas del entorno
    elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then
        obj.Enabled = false
    end
end

-- Ejecutar limpieza inicial en todo el mapa
for _, obj in ipairs(game:GetDescendants()) do
    pcall(potatoOptimize, obj)
end

-- Mantener la optimización y la luz baja activas para objetos nuevos
game.DescendantAdded:Connect(function(obj)
    pcall(potatoOptimize, obj)
end)

print("¡Optimización Ultra Potato y Anti-Brillo Activados!")
