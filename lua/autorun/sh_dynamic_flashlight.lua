CreateConVar("df_flashlight", 1, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Enable / Disable the dynamic flashlight system.")
CreateClientConVar("df_flashlight_shadow", 1, true, true, "Enable / Disable the shadows of the dynamic flashlight system.")
CreateClientConVar("df_flashlight_shadow_self", 1, true, true, "Enable / Disable the shadows of the dynamic flashlight system for yourself.")

if ( CLIENT ) then
    hook.Add("ShouldDrawShadows", "DynamicFlashlight.Shadows", function(entity)
        if not ( GetConVar("df_flashlight"):GetBool() ) then return end

        if ( entity == LocalPlayer() and GetConVar("df_flashlight_shadow"):GetBool() ) then
            return GetConVar("df_flashlight_shadow_self"):GetBool()
        end

        return GetConVar("df_flashlight_shadow"):GetBool()
    end)

    hook.Add("ShouldDrawFlashlight", "DynamicFlashlight.Flashlight", function(ply)
        if not ( GetConVar("df_flashlight"):GetBool() ) then return end

        return ply:GetNWBool("DynamicFlashlight")
    end)
    
    hook.Add("Think", "DynamicFlashlight.Rendering", function()
        local ply = LocalPlayer()

        for _, target in player.Iterator() do
            if ( hook.Run("ShouldDrawFlashlight", target) == true ) then
                if ( target.DynamicFlashlight ) then
                    local pos = target:EyePos()
                    local ang = target:EyeAngles()

                    pos = pos + ang:Forward() * 32

                    target.DynamicFlashlight:SetPos(pos)
                    target.DynamicFlashlight:SetAngles(ang)
                    target.DynamicFlashlight:Update()

                    local dlight = DynamicLight(target:EntIndex())
                    if ( dlight ) then
                        dlight.pos = pos
                        dlight.r = 255
                        dlight.g = 255
                        dlight.b = 255
                        dlight.brightness = 4
                        dlight.Decay = 1000
                        dlight.Size = 64
                        dlight.DieTime = CurTime() + 1
                    end
                else
                    target.DynamicFlashlight = ProjectedTexture()
                    target.DynamicFlashlight:SetTexture("effects/flashlight001")
                    target.DynamicFlashlight:SetFarZ(900)
                    target.DynamicFlashlight:SetFOV(70)
                    target.DynamicFlashlight:SetEnableShadows(hook.Run("ShouldDrawShadows", target))
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
        if not ( GetConVar("df_flashlight"):GetBool() ) then return end

        if not ( IsValid(ply) and ply:Alive() ) then return false end
        if ( ply:InVehicle() ) then return false end
        if ( ply:GetNoDraw() ) then return false end
        if ( hook.Run("PlayerCanSwitchFlashlight", ply, state) == false ) then return false end

        ply:SetNWBool("DynamicFlashlight", !ply:GetNWBool("DynamicFlashlight"))
        ply:EmitSound("HL2Player.FlashLightOn")

        return false
    end)

    hook.Add("PlayerSpawn", "DynamicFlashlight.Spawn", function(ply)
        if not ( GetConVar("df_flashlight"):GetBool() ) then return end

        ply:SetNWBool("DynamicFlashlight", false)
    end)

    hook.Add("PlayerEnteredVehicle", "DynamicFlashlight.Vehicle", function(ply, vehicle)
        if not ( GetConVar("df_flashlight"):GetBool() ) then return end

        ply:SetNWBool("DynamicFlashlight", false)
    end)

    hook.Add("PlayerNoClip", "DynamicFlashlight.NoClip", function(ply, state)
        if not ( GetConVar("df_flashlight"):GetBool() ) then return end

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
    if not ( GetConVar("df_flashlight"):GetBool() ) then
        return self:OldFlashlightIsOn()
    end

    return self:GetNWBool("DynamicFlashlight")
end