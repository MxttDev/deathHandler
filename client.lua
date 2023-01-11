isDead = false
playerPed = GetPlayerPed()
playerPedId = PlayerPedId()
playerId = PlayerId()
reviveWaitPeriod = 20
diedTime = nil
hasDied = false

function Draw2DText(x, y, text, scale, center) -- Function to create UI
    -- Draw text on screen
    SetTextFont(4)
    SetTextProportional(7)
    SetTextScale(scale, scale)
    SetTextColour(255, 255, 255, 255)
    SetTextDropShadow(0, 0, 0, 0,255)
    SetTextDropShadow()
    SetTextEdge(4, 0, 0, 0, 255)
    SetTextOutline()
    if center then 
    	SetTextJustification(0)
    end
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x, y)

end

function revivePed(ped) -- If player is revivde by admins / EMS
    local playerPos = GetEntityCoords(ped, true)

    ClearPedBloodDamage(ped)
    NetworkResurrectLocalPlayer(playerPos, true, true, false)

end

function playerDied(playerId, playerPed, died) --When the player dies
    hasDied = true
    local health = GetEntityHealth(PlayerPedId())

    seconds = 0
    StartScreenEffect("DeathFailOut", 0, 0)
    ShakeGameplayCam("DEATH_FAIL_IN_EFFECT_SHAKE", 1.0)

    while hasDied do
        local health = GetEntityHealth(PlayerPedId())
        local waitPeriod = died + (reviveWaitPeriod * 1000)

        if (health > 0) then 
            StopScreenEffect("DeathFailOut")
            hasDied = false 
        end

        if (GetGameTimer() >= waitPeriod) then 
            revivePed(PlayerPedId())
        end

        if (GetGameTimer() < waitPeriod) then 
            seconds = math.ceil((waitPeriod - GetGameTimer()) / 1000)
        end
        
        Draw2DText(.5, .80, "~w~You are ~b~unconcious~w~, press [~y~R~w~] to shout for ~b~help", .5, true)
        Draw2DText(.5, .83, "~w~You have ~b~"..seconds.."s ~w~until local doctor arrives.", .56, true)
       

       Citizen.Wait(5) -- Helps with server lag
    end
    StopScreenEffect("DeathFailOut")
end

Citizen.CreateThread(function()
    while true do 
        playerPed = GetPlayerPed()
        playerPedId = PlayerPedId()
    
        isDead = IsEntityDead(playerPedId)

        if isDead then
            if not hasDied then 
                died = GetGameTimer()
                playerDied(PlayerPedId, playerPed, died)
                
            end
        end

        Citizen.Wait(100)
    end
end)
