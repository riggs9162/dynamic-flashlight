CreateConVar("df_flashlight", 1, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Enable / Disable the dynamic flashlight system.")
CreateClientConVar("df_flashlight_shadow", 1, true, true, "Enable / Disable the shadows of the dynamic flashlight system.")
CreateClientConVar("df_flashlight_shadow_self", 1, true, true, "Enable / Disable the shadows of the dynamic flashlight system for yourself.")
CreateClientConVar("df_flashlight_fov", 70, true, true, "Set the field of view of the dynamic flashlight system.")
CreateClientConVar("df_flashlight_distance", 900, true, true, "Set the distance of the dynamic flashlight system.")
CreateClientConVar("df_flashlight_texture", "effects/flashlight001", true, true, "Set the texture of the dynamic flashlight system.")
CreateClientConVar("df_flashlight_sound", "HL2Player.FlashLightOn", true, true, "Set the sound of the dynamic flashlight system.")

if ( CLIENT ) then
    hook.Add("ShouldDrawShadows", "DynamicFlashlight.Shadows", function(entity)
        if ( !GetConVar("df_flashlight"):GetBool() ) then return end

        if ( entity == LocalPlayer() and GetConVar("df_flashlight_shadow"):GetBool() ) then
            return GetConVar("df_flashlight_shadow_self"):GetBool()
        end

        return GetConVar("df_flashlight_shadow"):GetBool()
    end)

    hook.Add("ShouldDrawFlashlight", "DynamicFlashlight.Flashlight", function(ply)
        if ( !GetConVar("df_flashlight"):GetBool() ) then return end

        return ply:GetNWBool("DynamicFlashlight")
    end)
    
    hook.Add("Think", "DynamicFlashlight.Rendering", function()
        local ply = LocalPlayer()

        if ( !GetConVar("df_flashlight"):GetBool() ) then return end

        local fov = GetConVar("df_flashlight_fov"):GetInt()
        local distance = GetConVar("df_flashlight_distance"):GetInt()
        local texture = GetConVar("df_flashlight_texture"):GetString()

        for _, target in player.Iterator() do
            if ( hook.Run("ShouldDrawFlashlight", target) == true ) then
                if ( target.DynamicFlashlight ) then
                    local pos = target:GetShootPos() + target:GetAimVector() * 32
                    local ang = target:EyeAngles()

                    pos = pos + ang:Forward() * 32

                    if ( !fov == target.DynamicFlashlightInfo.fov or !distance == target.DynamicFlashlightInfo.distance or !texture == target.DynamicFlashlightInfo.texture ) then
                        target.DynamicFlashlight:SetTexture(texture)
                        target.DynamicFlashlight:SetFarZ(distance)
                        target.DynamicFlashlight:SetFOV(fov)

                        target.DynamicFlashlightInfo.fov = fov
                        target.DynamicFlashlightInfo.distance = distance
                        target.DynamicFlashlightInfo.texture = texture
                    end

                    target.DynamicFlashlight:SetPos(pos)
                    target.DynamicFlashlight:SetAngles(ang)
                    target.DynamicFlashlight:Update()
                else
                    target.DynamicFlashlight = ProjectedTexture()
                    target.DynamicFlashlight:SetTexture(texture)
                    target.DynamicFlashlight:SetFarZ(distance)
                    target.DynamicFlashlight:SetFOV(fov)
                    target.DynamicFlashlight:SetEnableShadows(hook.Run("ShouldDrawShadows", target))

                    if ( !target.DynamicFlashlightInfo ) then
                        target.DynamicFlashlightInfo = {}
                    end

                    target.DynamicFlashlightInfo.fov = fov
                    target.DynamicFlashlightInfo.distance = distance
                    target.DynamicFlashlightInfo.texture = texture
                end
            else
                if ( target.DynamicFlashlight ) then
                    target.DynamicFlashlight:Remove()
                    target.DynamicFlashlight = nil
                end
            end
        end
    end)
else
    hook.Add("PlayerSwitchFlashlight", "DynamicFlashlight.Switch", function(ply, state)
        if ( !GetConVar("df_flashlight"):GetBool() ) then return end

        if ( !IsValid(ply) or !ply:Alive() ) then return false end
        if ( ply:InVehicle() ) then return false end
        if ( ply:GetNoDraw() ) then return false end
        if ( hook.Run("PlayerCanSwitchFlashlight", ply, state) == false ) then return false end

        ply:SetNWBool("DynamicFlashlight", !ply:GetNWBool("DynamicFlashlight"))
        ply:EmitSound("HL2Player.FlashLightOn")

        return false
    end)

    hook.Add("PlayerSpawn", "DynamicFlashlight.Spawn", function(ply)
        if ( !GetConVar("df_flashlight"):GetBool() ) then return end

        ply:SetNWBool("DynamicFlashlight", false)
    end)

    hook.Add("PlayerEnteredVehicle", "DynamicFlashlight.Vehicle", function(ply, vehicle)
        if ( !GetConVar("df_flashlight"):GetBool() ) then return end

        ply:SetNWBool("DynamicFlashlight", false)
    end)

    hook.Add("PlayerNoClip", "DynamicFlashlight.NoClip", function(ply, state)
        if ( !GetConVar("df_flashlight"):GetBool() ) then return end

        timer.Simple(0.1, function() // comment: ensure that the player is actually in noclip
            if ( IsValid(ply) and ply:GetMoveType() == MOVETYPE_NOCLIP and ply:GetNoDraw() ) then // comment: suppots gamemodes that make you invisible when noclip
                ply:SetNWBool("DynamicFlashlight", false)
            end
        end)
    end)
end

local PLAYER = FindMetaTable("Player")

PLAYER.OldFlashlightIsOn = PLAYER.OldFlashlightIsOn or PLAYER.FlashlightIsOn
function PLAYER:FlashlightIsOn()
    if ( !GetConVar("df_flashlight"):GetBool() ) then
        return self:OldFlashlightIsOn()
    end

    return self:GetNWBool("DynamicFlashlight")
end

PLAYER.OldFlashlight = PLAYER.OldFlashlight or PLAYER.Flashlight
function PLAYER:Flashlight(bool)
    if ( !GetConVar("df_flashlight"):GetBool() ) then
        if ( bool ) then
            self:OldFlashlight(true)
        else
            self:OldFlashlight(false)
        end
    end

    self:SetNWBool("DynamicFlashlight", bool)
    self:EmitSound("HL2Player.FlashLightOn")
end