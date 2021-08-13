if CLIENT then
    hook.Add("Think", "DynamicFlashlight", function()
        for _, v in ipairs(player.GetAll()) do
            if v:GetNWBool("DynamicFlashlight") then
                if IsValid(v.DynamicFlashlight) then
                    local vpos = v:GetPos()
                    local vang = v:GetAngles()
                    v.DynamicFlashlight:SetPos(Vector(vpos.x, vpos.y, vpos.z + 40) + v:GetForward() * 20)
                    v.DynamicFlashlight:SetAngles(vang)
                    v.DynamicFlashlight:SetFarZ(900)
                    v.DynamicFlashlight:SetFOV(70)
                    v.DynamicFlashlight:Update()
                else
                    v.DynamicFlashlight = ProjectedTexture()
                    v.DynamicFlashlight:SetTexture("effects/flashlight001")
                end
            else
                if IsValid(v.DynamicFlashlight) then
                    v.DynamicFlashlight:Remove()
                end
            end
        end
    end)
end

if SERVER then
    hook.Add("PlayerSwitchFlashlight", "DynamicFlashlightDefault", function(ply)
        ply:SetNWBool("DynamicFlashlight", not ply:GetNWBool("DynamicFlashlight"))
        ply:EmitSound("items/flashlight1.wav", 60, 100)

        return false
    end)
end
