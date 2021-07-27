DynamicFlashlight = {}

if CLIENT then
    local randommax = math.random(800, 1000)
    if (IsValid(LocalPlayer())) then
        local plypos = LocalPlayer():GetPos()
        local plyang = LocalPlayer():GetAngles()
        local projectedlight = ProjectedTexture()
        DynamicFlashlight.LightProjected = projectedlight

        DynamicFlashlight.LightProjected:SetTexture("effects/flashlight001")
        DynamicFlashlight.LightProjected:SetPos(Vector(plypos.x, plypos.y, plypos.z + 40))
        DynamicFlashlight.LightProjected:SetAngles(plyang)
        DynamicFlashlight.LightProjected:SetFarZ(randommax)
        DynamicFlashlight.LightProjected:SetFOV(70)

        DynamicFlashlight.LightProjected:Update()
    end

    local function UpdateFlashlight()
        local plypos = LocalPlayer():GetPos()
        local plyang = LocalPlayer():GetAngles()
        plypos = LerpVector(0.1, plypos, LocalPlayer():GetPos())
        plyang = LerpAngle(0.05, plyang, LocalPlayer():GetAngles())
        if IsValid(DynamicFlashlight.LightProjected) then
            randommax = Lerp(0.001, randommax, math.random(800,2000))
            DynamicFlashlight.LightProjected:SetPos(Vector(plypos.x, plypos.y, plypos.z + 40) + LocalPlayer():GetForward() * 20)
            DynamicFlashlight.LightProjected:SetAngles(plyang)
            DynamicFlashlight.LightProjected:SetFarZ(randommax)
            DynamicFlashlight.LightProjected:SetFOV(70)
            DynamicFlashlight.LightProjected:Update()

            glowinglight = DynamicLight(LocalPlayer():EntIndex())
            DynamicFlashlight.Light = glowinglight
            if (DynamicFlashlight.Light) then
                DynamicFlashlight.Light.pos = Vector(plypos.x, plypos.y, plypos.z + 40) + LocalPlayer():GetForward() * 20
                DynamicFlashlight.Light.r = 255
                DynamicFlashlight.Light.g = 255
                DynamicFlashlight.Light.b = 255
                DynamicFlashlight.Light.brightness = 1
                DynamicFlashlight.Light.Decay = 1000
                DynamicFlashlight.Light.Size = 200
                DynamicFlashlight.Light.DieTime = CurTime() + 1
            end
        end
    end

    hook.Add("Think", "DynamicFlashlight", function()
	    if (LocalPlayer():GetNWBool("DynamicFlashlight") == true) then
            if IsValid(DynamicFlashlight.LightProjected) then
                UpdateFlashlight()
            else
                local projectedlight = ProjectedTexture()
                DynamicFlashlight.LightProjected = projectedlight

                DynamicFlashlight.LightProjected:SetTexture("effects/flashlight001")
            end
        else
            if IsValid(DynamicFlashlight.LightProjected) then
                DynamicFlashlight.LightProjected:Remove()
            end
        end
    end)
end

if SERVER then
    hook.Add("PlayerSwitchFlashlight", "DynamicFlashlightDefault", function(ply)
        ply:SetNWBool("DynamicFlashlight", !ply:GetNWBool("DynamicFlashlight"))
        if ply:GetNWBool("DynamicFlashlight") == true then
            ply:EmitSound("items/flashlight1.wav", 60, 100)
        else
            ply:EmitSound("buttons/lightswitch2.wav", 60, 50)
        end

        return false
    end)
end