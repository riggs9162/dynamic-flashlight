if CLIENT then
    local cache = {}
    local function UpdateCache(entity, state)
        if not entity:IsPlayer() then return end

        if state then
            table.insert(cache, entity)
        else
            for i = 1, #cache do
                if cache[i] == entity then
                    table.remove(cache, i)
                end
            end
        end
    end

    hook.Add("NotifyShouldTransmit", "DynamicFlashlight.PVS_Cache", function(entity, state)
        UpdateCache(entity, state)
    end)

    hook.Add("EntityRemoved", "DynamicFlashlight.PVS_Cache", function(entity)
        UpdateCache(entity, false)
    end)

    hook.Add("Think", "DynamicFlashlight.Rendering", function()
        for i = 1, #cache do
            local target = cache[i]

            if target:GetNWBool("DynamicFlashlight") then
                if target.DynamicFlashlight then
                    local position = target:GetPos()

                    target.DynamicFlashlight:SetPos(Vector(position[1], position[2], position[3] + 40) + target:GetForward() * 20)
                    target.DynamicFlashlight:SetAngles(target:EyeAngles())
                    target.DynamicFlashlight:Update()
                else
                    target.DynamicFlashlight = ProjectedTexture()
                    target.DynamicFlashlight:SetTexture("effects/flashlight001")
                    target.DynamicFlashlight:SetFarZ(900)
                    target.DynamicFlashlight:SetFOV(70)
                end
            else
                if target.DynamicFlashlight then
                    target.DynamicFlashlight:Remove()
                    target.DynamicFlashlight = nil
                end
            end
        end
    end)
else
    hook.Add("PlayerSwitchFlashlight", "DynamicFlashlight.Switch", function(ply, state)
        ply:SetNWBool("DynamicFlashlight", not ply:GetNWBool("DynamicFlashlight"))
        ply:EmitSound("items/flashlight1.wav", 60, 100)

        return false
    end)
end
