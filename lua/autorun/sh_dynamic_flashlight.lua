if CLIENT then
    for k, v in ipairs(player.GetAll()) do
        if (IsValid(v)) then
            v.DynamicFlashlight = {}

            local plypos = v:GetPos()
            local plyang = v:GetAngles()
            local projectedlight = ProjectedTexture()
            v.DynamicFlashlight.LightProjected = projectedlight

            v.DynamicFlashlight.LightProjected:SetTexture("effects/flashlight001")
            v.DynamicFlashlight.LightProjected:SetPos(Vector(plypos.x, plypos.y, plypos.z + 40))
            v.DynamicFlashlight.LightProjected:SetAngles(plyang)
            v.DynamicFlashlight.LightProjected:SetFarZ(900)
            v.DynamicFlashlight.LightProjected:SetFOV(70)

            v.DynamicFlashlight.LightProjected:Update()
        end
    end

    hook.Add("Think", "DynamicFlashlight", function()
        for k, v in ipairs(player.GetAll()) do
            if (IsValid(v)) then
                if (v:GetNWBool("DynamicFlashlight") == true) then
                    if IsValid(v.DynamicFlashlight.LightProjected) then
                        local vpos = v:GetPos()
                        local vang = v:GetAngles()
                        v.DynamicFlashlight.LightProjected:SetPos(Vector(vpos.x, vpos.y, vpos.z + 40) + v:GetForward() * 20)
                        v.DynamicFlashlight.LightProjected:SetAngles(vang)
                        v.DynamicFlashlight.LightProjected:SetFarZ(900)
                        v.DynamicFlashlight.LightProjected:SetFOV(70)
                        v.DynamicFlashlight.LightProjected:Update()
                    else
                        local projectedlight = ProjectedTexture()
                        v.DynamicFlashlight.LightProjected = projectedlight

                        v.DynamicFlashlight.LightProjected:SetTexture("effects/flashlight001")
                    end
                else
                    if IsValid(v.DynamicFlashlight.LightProjected) then
                        v.DynamicFlashlight.LightProjected:Remove()
                    end
                end
            end
        end
    end)
end

if SERVER then
    hook.Add("PlayerSwitchFlashlight", "DynamicFlashlightDefault", function(ply)
        ply:SetNWBool("DynamicFlashlight", !ply:GetNWBool("DynamicFlashlight"))
        ply:EmitSound("items/flashlight1.wav", 60, 100)

        return false
    end)
end
