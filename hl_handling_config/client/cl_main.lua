-- --- [[[
-- --- Variables
-- --- ]]]

local modifiedVehicles = {}
local originalVehicles = {}

-- Blacklist de modelos (não serão tocados pelo script)
local blacklist = {
    [`alpha`] = true,
    [`baller`] = true,
    [`baller2`] = true,
    [`baller3`] = true,
    [`baller4`] = true,
    [`baller5`] = true,
    [`baller6`] = true,
    [`baller7`] = true,
    [`buffalo`] = true,
    [`buffalo2`] = true,
    [`cavalcade`] = true,
    [`cavalcade2`] = true,
    [`dorado`] = true,
    [`dominator`] = true,
    [`dukes`] = true,
    [`drafter`] = true,
    [`exemplar`] = true,
    [`rocoto`] = true,
    [`f620`] = true,
    [`firebolt`] = true,
    [`yosemite3`] = true,
    [`keitora`] = true,
    [`z190`] = true,
}

-- Off Road Terrains
local slipperySurfaceMaterial = {
    [9] = true, [10] = true, [11] = true,      -- ROCK, ROCK_MOSSY, STONE
    [17] = true, [18] = true, [19] = true,     -- SANDSTONE_BRITTLE, SAND_LOOSE, SAND_COMPACT
    [20] = true, [21] = true, [22] = true,     -- SAND_WET, SAND_TRACK, SAND_UNDERWATER
    [23] = true, [24] = true,                   -- SAND_DRY_DEEP, SAND_WET_DEEP
    [31] = true, [32] = true, [33] = true,     -- GRAVEL_SMALL, GRAVEL_LARGE, GRAVEL_DEEP
    [34] = true, [35] = true,                   -- GRAVEL_TRAIN_TRACK, DIRT_TRACK
    [36] = true, [37] = true, [38] = true,     -- MUD_HARD, MUD_POTHOLE, MUD_SOFT
    [39] = true, [40] = true,                   -- MUD_UNDERWATER, MUD_DEEP
    [41] = true, [42] = true,                   -- MARSH, MARSH_DEEP
    [43] = true, [44] = true, [45] = true,     -- SOIL, CLAY_HARD, CLAY_SOFT
    [46] = true, [47] = true, [48] = true,     -- GRASS_LONG, GRASS, GRASS_SHORT
    [55] = true,                                 -- METAL_SOLID_SMALL
}

-- ============================================================================
-- PER-CLASS HANDLING CONFIGURATION
-- Multipliers (_mult) are applied to the vehicle's default GTA handling values
-- Direct values override the current value entirely
-- Vehicle Classes: 0=Compacts, 1=Sedans, 2=SUVs, 3=Coupes, 4=Muscle,
--   5=Sports Classics, 6=Sports, 7=Super, 8=Motorcycles, 9=Off-road,
--   10=Industrial, 11=Utility, 12=Vans, 13=Cycles, 14+=Boats/Helis/Planes
-- ============================================================================

local classConfig = {
    -- Compacts
    [0] = {
        fInitialDriveForce_mult     = 0.65, -- Força de aceleração inicial
        fInitialDriveMaxFlatVel_mult = 0.90, -- Velocidade máxima final
        fSteeringLock_mult          = 0.53, -- Ângulo de esterçamento das rodas
        fTractionCurveMax_mult      = 1.00, -- Tração máxima (aderência)
        fTractionCurveMin_mult      = 1.10, -- Tração mínima
        fTractionCurveLateral_mult  = 0.74, -- Tração lateral (curvas)
        fBrakeForce_mult            = 1.25, -- Força de frenagem
        fSuspensionForce_mult       = 0.58, -- Rigidez da suspensão
        fSuspensionUpperLimit_mult  = 1.5,  -- Curso da suspensão para cima (Absorção)
        fSuspensionLowerLimit_mult  = 1.2,  -- Curso da suspensão para baixo
        fTractionLossMult           = 0.80, -- Perda de tração
        fAntiRollBarForce           = 0.15, -- Barra estabilizadora
        fRollCentreHeightFront      = 0.25, -- Altura do centro de rolagem frontal
        fRollCentreHeightRear       = 0.25, -- Altura do centro de rolagem traseiro
    },
    -- Sedans
    [1] = {
        fInitialDriveForce_mult     = 0.65,
        fInitialDriveMaxFlatVel_mult = 1.00,
        fSteeringLock_mult          = 0.68,
        fTractionCurveMax_mult      = 0.78,
        fTractionCurveMin_mult      = 0.80,
        fTractionCurveLateral_mult  = 0.75,
        fBrakeForce_mult            = 1.15,
        fSuspensionForce_mult       = 0.78,
        fSuspensionUpperLimit_mult  = 1.3,
        fSuspensionLowerLimit_mult  = 1.0,
        fTractionLossMult           = 1.50,
        fAntiRollBarForce           = 0.20,
        fRollCentreHeightFront      = 0.22,
        fRollCentreHeightRear       = 0.22,
    },
    -- SUVs
    [2] = {
        fInitialDriveForce_mult     = 0.85,
        fInitialDriveMaxFlatVel_mult = 0.80,
        fSteeringLock_mult          = 0.76,
        fTractionCurveMax_mult      = 0.85,
        fTractionCurveMin_mult      = 0.97,
        fTractionCurveLateral_mult  = 0.87,
        fBrakeForce_mult            = 1.25,
        fSuspensionForce_mult       = 0.88,
        fSuspensionUpperLimit_mult  = 1.50,
        fSuspensionLowerLimit_mult  = 1.20,
        fTractionLossMult           = 1.10,
        fAntiRollBarForce           = 0.15,
        fRollCentreHeightFront      = 0.27,
        fRollCentreHeightRear       = 0.20,
    },
    -- Coupes
    [3] = {
        fInitialDriveForce_mult     = 0.63,
        fInitialDriveMaxFlatVel_mult = 1.00,
        fSteeringLock_mult          = 0.73,
        fTractionCurveMax_mult      = 0.76,
        fTractionCurveMin_mult      = 0.82,
        fTractionCurveLateral_mult  = 0.73,
        fBrakeForce_mult            = 0.94,
        fSuspensionForce_mult       = 0.52,
        fSuspensionUpperLimit_mult  = 1.25,
        fSuspensionLowerLimit_mult  = 1.2,
        fTractionLossMult           = 2.00,
        fAntiRollBarForce           = 0.225,
        fRollCentreHeightFront      = 0.10,
        fRollCentreHeightRear       = 0.10,
    },
    -- Muscle
    [4] = {
        fInitialDriveForce_mult     = 0.57,
        fInitialDriveMaxFlatVel_mult = 1.05,
        fSteeringLock_mult          = 0.64,
        fTractionCurveMax_mult      = 0.87,
        fTractionCurveMin_mult      = 0.87,
        fTractionCurveLateral_mult  = 0.80,
        fBrakeForce_mult            = 1.42,
        fSuspensionForce_mult       = 0.63,
        fSuspensionUpperLimit_mult  = 1.40,
        fSuspensionLowerLimit_mult  = 1.20,
        fTractionLossMult           = 2.00,
        fAntiRollBarForce           = 0.10,
        fRollCentreHeightFront      = 0.15,
        fRollCentreHeightRear       = 0.15,
    },
    -- Sports Classics
    [5] = {
        fInitialDriveForce_mult     = 0.60,
        fInitialDriveMaxFlatVel_mult = 1.00,
        fSteeringLock_mult          = 0.68,
        fTractionCurveMax_mult      = 0.78,
        fTractionCurveMin_mult      = 0.80,
        fTractionCurveLateral_mult  = 0.75,
        fBrakeForce_mult            = 1.15,
        fSuspensionForce_mult       = 1.00,
        fSuspensionUpperLimit_mult  = 1.00,
        fSuspensionLowerLimit_mult  = 1.00,
        fTractionLossMult           = 1.50,
        fAntiRollBarForce           = 0.20,
        fRollCentreHeightFront      = 0.10,
        fRollCentreHeightRear       = 0.10,
    },
    -- Sports
    [6] = {
        fInitialDriveForce_mult     = 0.60,
        fInitialDriveMaxFlatVel_mult = 1.00,
        fSteeringLock_mult          = 0.65,
        fTractionCurveMax_mult      = 0.73,
        fTractionCurveMin_mult      = 0.69,
        fTractionCurveLateral_mult  = 0.71,
        fBrakeForce_mult            = 0.89,
        fSuspensionForce_mult       = 0.85,
        fSuspensionUpperLimit_mult  = 1.40,
        fSuspensionLowerLimit_mult  = 1.20,
        fTractionLossMult           = 2.00,
        fAntiRollBarForce           = 0.30,
        fRollCentreHeightFront      = 0.10,
        fRollCentreHeightRear       = 0.10,
    },
    -- Super
    [7] = {
        fInitialDriveForce_mult     = 0.71,
        fInitialDriveMaxFlatVel_mult = 0.70,
        fInitialDragCoeff_mult      = 0.80,
        fSteeringLock_mult          = 0.52,
        fTractionCurveMax_mult      = 0.74,
        fTractionCurveMin_mult      = 0.67,
        fTractionCurveLateral_mult  = 0.71,
        fBrakeForce_mult            = 0.85,
        fSuspensionForce_mult       = 0.87,
        fSuspensionUpperLimit_mult  = 1.40,
        fSuspensionLowerLimit_mult  = 1.20,
        fTractionLossMult           = 2.00,
        fAntiRollBarForce           = 0.30,
        fRollCentreHeightFront      = 0.20,
        fRollCentreHeightRear       = 0.27,
    },
    -- Off-roads
    [9] = {
        fInitialDriveForce_mult     = 0.56,
        fInitialDriveMaxFlatVel_mult = 0.95,
        fSteeringLock_mult          = 0.59,
        fTractionCurveMax_mult      = 0.77,
        fTractionCurveMin_mult      = 0.76,
        fTractionCurveLateral_mult  = 0.71,
        fBrakeForce_mult            = 1.36,
        fSuspensionForce_mult       = 0.57,
        fSuspensionUpperLimit_mult  = 1.30,
        fSuspensionLowerLimit_mult  = 1.20,
        fTractionLossMult           = 1.50,
        fAntiRollBarForce           = 0.30,
        fAntiRollBarBiasFront       = 0.60,
        fRollCentreHeightFront      = 0.175,
        fRollCentreHeightRear       = 0.175,
    },
    -- Industrial
    [10] = {
        fInitialDriveForce_mult     = 1.09,
        fInitialDriveMaxFlatVel_mult = 1.00,
        fSteeringLock_mult          = 0.62,
        fTractionCurveMax_mult      = 1.06,
        fTractionCurveMin_mult      = 1.14,
        fTractionCurveLateral_mult  = 1.09,
        fBrakeForce_mult            = 2.40,
        fSuspensionForce_mult       = 0.71,
        fSuspensionUpperLimit_mult  = 1.20,
        fSuspensionLowerLimit_mult  = 1.00,
        fTractionLossMult           = 1.50,
        fAntiRollBarForce           = 0.0,
        fRollCentreHeightFront      = 0.24,
        fRollCentreHeightRear       = 0.24,
    },
    -- Utility
    [11] = {
        fInitialDriveForce_mult     = 1.09,
        fInitialDriveMaxFlatVel_mult = 1.00,
        fSteeringLock_mult          = 0.62,
        fTractionCurveMax_mult      = 1.06,
        fTractionCurveMin_mult      = 1.14,
        fTractionCurveLateral_mult  = 1.09,
        fBrakeForce_mult            = 2.40,
        fSuspensionForce_mult       = 0.71,
        fSuspensionUpperLimit_mult  = 1.40,
        fSuspensionLowerLimit_mult  = 1.20,
        fTractionLossMult           = 1.50,
        fAntiRollBarForce           = 0.0,
        fRollCentreHeightFront      = 0.24,
        fRollCentreHeightRear       = 0.24,
    },
    -- Vans
    [12] = {
        fInitialDriveForce_mult     = 0.64,
        fInitialDriveMaxFlatVel_mult = 1.00,
        fSteeringLock_mult          = 0.66,
        fTractionCurveMax_mult      = 0.87,
        fTractionCurveMin_mult      = 0.94,
        fTractionCurveLateral_mult  = 0.80,
        fBrakeForce_mult            = 1.00,
        fSuspensionForce_mult       = 0.98,
        fSuspensionUpperLimit_mult  = 1.40,
        fSuspensionLowerLimit_mult  = 1.20,
        fTractionLossMult           = 1.50,
        fAntiRollBarForce           = 0.00,
        fRollCentreHeightFront      = 0.40,
        fRollCentreHeightRear       = 0.40,
    },
    -- Commercial
    [20] = {
        fInitialDriveForce_mult     = 0.90,
        fInitialDriveMaxFlatVel_mult = 1.00,
        fSteeringLock_mult          = 0.64,
        fTractionCurveMax_mult      = 0.95,
        fTractionCurveMin_mult      = 1.00,
        fTractionCurveLateral_mult  = 0.90,
        fBrakeForce_mult            = 1.80,
        fSuspensionForce_mult       = 0.95,
        fSuspensionUpperLimit_mult  = 1.20,
        fSuspensionLowerLimit_mult  = 1.00,
        fTractionLossMult           = 1.50,
        fAntiRollBarForce           = 0.0,
        fRollCentreHeightFront      = 0.50,
        fRollCentreHeightRear       = 0.50,
    },
}

-- Config padrão para classes não especificadas (média geral)
local defaultClassConfig = {
    fInitialDriveForce_mult     = 0.60,
    fInitialDriveMaxFlatVel_mult = 1.00,
    fSteeringLock_mult          = 0.68,
    fTractionCurveMax_mult      = 0.78,
    fTractionCurveMin_mult      = 0.80,
    fTractionCurveLateral_mult  = 0.75,
    fBrakeForce_mult            = 1.15,
    fSuspensionForce_mult       = 0.35,
    fSuspensionUpperLimit_mult  = 1.4,
    fSuspensionLowerLimit_mult  = 1.4,
    fTractionLossMult           = 1.50,
    fAntiRollBarForce           = 0.20,
    fRollCentreHeightFront      = 0.30,
    fRollCentreHeightRear       = 0.30,
}

-- ============================================================================
-- FUNCTIONS
-- ============================================================================

--- Get the config for a vehicle class
local function GetClassConfig(vehClass)
    return classConfig[vehClass] or defaultClassConfig
end

--- Apply handling modifications to a vehicle
function AdjustVehicleHandling(plyVeh)
    NetworkRegisterEntityAsNetworked(plyVeh)

    local model = GetEntityModel(plyVeh)
    local isBlacklisted = blacklist[model]

    local vehClass = GetVehicleClass(plyVeh)
    local cfg = GetClassConfig(vehClass)

    -- Universal fixed values
    SetVehicleHandlingFloat(plyVeh, "CHandlingData", "fLowSpeedTractionLossMult", 0.0)
    SetVehicleHandlingFloat(plyVeh, "CHandlingData", "fDriveInertia", 1.55)
    SetVehicleHandlingFloat(plyVeh, "CHandlingData", "fHandBrakeForce", 0.8)
    SetVehicleHandlingFloat(plyVeh, "CHandlingData", "fEngineDamageMult", 1.0)
    SetVehicleHandlingFloat(plyVeh, "CHandlingData", "fDeformationDamageMult", 2.0)
    SetVehicleHandlingFloat(plyVeh, "CHandlingData", "fDownforceModifier", 10.0)
    SetVehicleHandlingFloat(plyVeh, "CHandlingData", "fBrakeBiasFront", 0.65)

    SetVehicleHandlingInt(plyVeh, "CCarHandlingData", "strAdvancedFlags", 201326592)
    SetVehicleHandlingInt(plyVeh, "CHandlingData", "strHandlingFlags", 8520960) -- 0x820100

    -- Per-class multipliers (Direct application)
    local fInitialDriveForce = GetVehicleHandlingFloat(plyVeh, "CHandlingData", "fInitialDriveForce")
    local fInitialDriveMaxFlatVel = GetVehicleHandlingFloat(plyVeh, "CHandlingData", "fInitialDriveMaxFlatVel")
    local fSteeringLock = GetVehicleHandlingFloat(plyVeh, "CHandlingData", "fSteeringLock")
    local fTractionCurveMax = GetVehicleHandlingFloat(plyVeh, "CHandlingData", "fTractionCurveMax")
    local fTractionCurveMin = GetVehicleHandlingFloat(plyVeh, "CHandlingData", "fTractionCurveMin")
    local fTractionCurveLateral = GetVehicleHandlingFloat(plyVeh, "CHandlingData", "fTractionCurveLateral")
    local fBrakeForce = GetVehicleHandlingFloat(plyVeh, "CHandlingData", "fBrakeForce")
    local fSuspensionForce = GetVehicleHandlingFloat(plyVeh, "CHandlingData", "fSuspensionForce")
    local fSuspensionUpperLimit = GetVehicleHandlingFloat(plyVeh, "CHandlingData", "fSuspensionUpperLimit")
    local fSuspensionLowerLimit = GetVehicleHandlingFloat(plyVeh, "CHandlingData", "fSuspensionLowerLimit")

    SetVehicleHandlingFloat(plyVeh, "CHandlingData", "fInitialDriveForce", fInitialDriveForce * cfg.fInitialDriveForce_mult)
    SetVehicleHandlingFloat(plyVeh, "CHandlingData", "fInitialDriveMaxFlatVel", fInitialDriveMaxFlatVel * cfg.fInitialDriveMaxFlatVel_mult)
    SetVehicleHandlingFloat(plyVeh, "CHandlingData", "fSteeringLock", fSteeringLock * cfg.fSteeringLock_mult)
    SetVehicleHandlingFloat(plyVeh, "CHandlingData", "fTractionCurveMax", fTractionCurveMax * cfg.fTractionCurveMax_mult)
    SetVehicleHandlingFloat(plyVeh, "CHandlingData", "fTractionCurveMin", fTractionCurveMin * cfg.fTractionCurveMin_mult)
    SetVehicleHandlingFloat(plyVeh, "CHandlingData", "fTractionCurveLateral", fTractionCurveLateral * cfg.fTractionCurveLateral_mult)
    SetVehicleHandlingFloat(plyVeh, "CHandlingData", "fBrakeForce", fBrakeForce * cfg.fBrakeForce_mult)

    if not isBlacklisted then
        SetVehicleHandlingFloat(plyVeh, "CHandlingData", "fSuspensionForce", fSuspensionForce * cfg.fSuspensionForce_mult)
        SetVehicleHandlingFloat(plyVeh, "CHandlingData", "fSuspensionUpperLimit", fSuspensionUpperLimit * cfg.fSuspensionUpperLimit_mult)
        SetVehicleHandlingFloat(plyVeh, "CHandlingData", "fSuspensionLowerLimit", fSuspensionLowerLimit * cfg.fSuspensionLowerLimit_mult)
    end

    -- Force Engine Power
    SetVehicleEnginePowerMultiplier(plyVeh, cfg.fInitialDriveForce_mult)

    -- Debug em Estilo XML (F8)
    print(string.format("^3<Item type=\"CHandlingData\"> -- [Classe %s]^7", vehClass))
    print(string.format("  <fInitialDriveForce value=\"%.6f\" />", GetVehicleHandlingFloat(plyVeh, "CHandlingData", "fInitialDriveForce")))
    print(string.format("  <fInitialDriveMaxFlatVel value=\"%.6f\" />", GetVehicleHandlingFloat(plyVeh, "CHandlingData", "fInitialDriveMaxFlatVel")))
    print(string.format("  <fSteeringLock value=\"%.6f\" />", GetVehicleHandlingFloat(plyVeh, "CHandlingData", "fSteeringLock")))
    print(string.format("  <fTractionCurveMax value=\"%.6f\" />", GetVehicleHandlingFloat(plyVeh, "CHandlingData", "fTractionCurveMax")))
    print(string.format("  <fTractionCurveMin value=\"%.6f\" />", GetVehicleHandlingFloat(plyVeh, "CHandlingData", "fTractionCurveMin")))
    print(string.format("  <fTractionCurveLateral value=\"%.6f\" />", GetVehicleHandlingFloat(plyVeh, "CHandlingData", "fTractionCurveLateral")))
    print(string.format("  <fBrakeForce value=\"%.6f\" />", GetVehicleHandlingFloat(plyVeh, "CHandlingData", "fBrakeForce")))
    print(string.format("  <fSuspensionForce value=\"%.6f\" />", GetVehicleHandlingFloat(plyVeh, "CHandlingData", "fSuspensionForce")))
    print(string.format("  <fSuspensionUpperLimit value=\"%.6f\" />", GetVehicleHandlingFloat(plyVeh, "CHandlingData", "fSuspensionUpperLimit")))
    print(string.format("  <fSuspensionLowerLimit value=\"%.6f\" />", GetVehicleHandlingFloat(plyVeh, "CHandlingData", "fSuspensionLowerLimit")))
    print(string.format("  <fAntiRollBarForce value=\"%.6f\" />", GetVehicleHandlingFloat(plyVeh, "CHandlingData", "fAntiRollBarForce")))
    print(string.format("  <fRollCentreHeightFront value=\"%.6f\" />", GetVehicleHandlingFloat(plyVeh, "CHandlingData", "fRollCentreHeightFront")))
    print(string.format("  <fRollCentreHeightRear value=\"%.6f\" />", GetVehicleHandlingFloat(plyVeh, "CHandlingData", "fRollCentreHeightRear")))
    print("^3</Item>^7")

    -- Per-class direct values
    SetVehicleHandlingFloat(plyVeh, "CHandlingData", "fTractionLossMult", cfg.fTractionLossMult)

    -- Roll parameters
    SetVehicleHandlingFloat(plyVeh, "CHandlingData", "fAntiRollBarForce", cfg.fAntiRollBarForce)
    if not isBlacklisted then
        SetVehicleHandlingFloat(plyVeh, "CHandlingData", "fRollCentreHeightFront", cfg.fRollCentreHeightFront)
        SetVehicleHandlingFloat(plyVeh, "CHandlingData", "fRollCentreHeightRear", cfg.fRollCentreHeightRear)
    end
    if cfg.fAntiRollBarBiasFront then
        SetVehicleHandlingFloat(plyVeh, "CHandlingData", "fAntiRollBarBiasFront", cfg.fAntiRollBarBiasFront)
    end

    StoreOriginalVehicleHandling(plyVeh)
    SetVehicleHasBeenOwnedByPlayer(plyVeh, true)
end

--- Store original vehicle handling values (for offroad toggle)
function StoreOriginalVehicleHandling(plyVeh)
    if not originalVehicles[plyVeh] then
        originalVehicles[plyVeh] = {
            fTractionLossMult = GetVehicleHandlingFloat(plyVeh, "CHandlingData", "fTractionLossMult"),
            fTractionCurveMin = GetVehicleHandlingFloat(plyVeh, "CHandlingData", "fTractionCurveMin"),
            fLowSpeedTractionLossMult = GetVehicleHandlingFloat(plyVeh, "CHandlingData", "fLowSpeedTractionLossMult"),
            fDriveBiasFront = GetVehicleHandlingFloat(plyVeh, "CHandlingData", "fDriveBiasFront"),
        }
    end
end

--- Restore original vehicle handling values
function RestoreOriginalVehicleHandling(plyVeh)
    if originalVehicles[plyVeh] then
        SetVehicleHandlingFloat(plyVeh, "CHandlingData", "fTractionLossMult", originalVehicles[plyVeh].fTractionLossMult)
        SetVehicleHandlingFloat(plyVeh, "CHandlingData", "fTractionCurveMin", originalVehicles[plyVeh].fTractionCurveMin)
        SetVehicleHandlingFloat(plyVeh, "CHandlingData", "fLowSpeedTractionLossMult", originalVehicles[plyVeh].fLowSpeedTractionLossMult)
    end
end

--- Toggle off-road state
function toggleOffroadState(pState)
    if plyVeh ~= nil and originalVehicles[plyVeh] then
        local isAWD = (originalVehicles[plyVeh].fDriveBiasFront > 0 and originalVehicles[plyVeh].fDriveBiasFront < 1)
        local tractionFactor = isAWD and 0.8 or 0.9

        if pState then
            local fTractionLossMult = GetVehicleHandlingFloat(plyVeh, "CHandlingData", "fTractionLossMult")
            local fTractionCurveMin = GetVehicleHandlingFloat(plyVeh, "CHandlingData", "fTractionCurveMin")
            local fLowSpeedTractionLossMult = GetVehicleHandlingFloat(plyVeh, "CHandlingData", "fLowSpeedTractionLossMult")

            SetVehicleHandlingFloat(plyVeh, "CHandlingData", "fTractionLossMult", fTractionLossMult * 1.5)
            SetVehicleHandlingFloat(plyVeh, "CHandlingData", "fTractionCurveMin", fTractionCurveMin * tractionFactor)
            SetVehicleHandlingFloat(plyVeh, "CHandlingData", "fLowSpeedTractionLossMult", fLowSpeedTractionLossMult * 1.5)
        else
            RestoreOriginalVehicleHandling(plyVeh)
        end
    end
end

-- ============================================================================
-- MAIN THREAD
-- ============================================================================

local Driver
local plyVeh = 0

Citizen.CreateThread(function()
    local isOffroad = false
    local offroadTicks = 0

    while true do
        local PlayerPed = PlayerPedId()
        plyVeh = GetVehiclePedIsIn(PlayerPed, false)

        if plyVeh == 0 then
            isOffroad = false
            offroadTicks = 0
            Citizen.Wait(500)
        else
            local IsDriver = GetPedInVehicleSeat(plyVeh, -1) == PlayerPed
            local IsCarModel = IsThisModelACar(GetEntityModel(plyVeh))
            Driver = IsDriver and IsCarModel

            -- Apply one-time handling modifications
            if Driver and not modifiedVehicles[plyVeh] then
                modifiedVehicles[plyVeh] = true
                AdjustVehicleHandling(plyVeh)
            end

            -- Off Road Detection
            local s0 = GetVehicleWheelSurfaceMaterial(plyVeh, 0)
            local s1 = GetVehicleWheelSurfaceMaterial(plyVeh, 1)
            local s2 = GetVehicleWheelSurfaceMaterial(plyVeh, 2)
            local s3 = GetVehicleWheelSurfaceMaterial(plyVeh, 3)
            local isSlippery = slipperySurfaceMaterial[s0]
                or slipperySurfaceMaterial[s1]
                or slipperySurfaceMaterial[s2]
                or slipperySurfaceMaterial[s3]

            if isSlippery and offroadTicks < 5 then
                offroadTicks = offroadTicks + 1
            elseif not isSlippery and offroadTicks >= 1 then
                offroadTicks = offroadTicks - 1
            end

            if isSlippery and not isOffroad and offroadTicks > 3 then
                isOffroad = true
                toggleOffroadState(true)
            elseif isOffroad and offroadTicks < 3 then
                isOffroad = false
                toggleOffroadState(false)
            end

            Citizen.Wait(100)
        end
    end
end)