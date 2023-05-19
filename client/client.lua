ESX = exports.es_extended:getSharedObject()
local cordinatechiamata = nil
local aperto = false
local notificasparo = false

exports('SendDispatch', function(code)
    local ped = PlayerPedId()
    local coordsped = GetEntityCoords(ped)
    cordinatechiamata = coordsped
    TriggerServerEvent('yd:dispatch:getpolice', code)
end)

Citizen.CreateThread(function()
    while true do
        Wait(0)
        local ped = PlayerPedId()
        local coordsped = GetEntityCoords(ped)
        local inveicolo = IsPedInAnyVehicle(ped, false)
        local veicolo = GetVehiclePedIsIn(ped)
        local modello = GetEntityModel(veicolo)
        local VehicleName = GetDisplayNameFromVehicleModel(modello)

        if Config.Shooting.Active then
            if IsPedShooting(ped) then
                cordinatechiamata = coordsped
                if not notificasparo then
                    TriggerServerEvent('yd:dispatch:getpolice', Config.Shooting.Code)
                    notificasparo = true
                else
                    Wait(Config.Shooting.Wait)
                    notificasparo = false
                end
            end
        end

        if Config.PanicButton.Active then
            if inveicolo and IsControlJustPressed(0, Config.PanicButton.Key) then
                cordinatechiamata = coordsped
                for k, r in pairs(Config.PanicButton.Vehicle) do
                    if VehicleName == r then
                        TriggerServerEvent('yd:dispatch:getpolice', Config.PanicButton.Code)
                    end
                end
            end
        end
        Wait(1500)
    end 
end)

RegisterNetEvent('yd:dispatch:send', function(code)
    if not aperto then
        aperto = true
        SendNUIMessage({
            open = aperto,
            Code = code,
        })
        Citizen.CreateThread(function()
            while aperto do
                Wait(0)
                if IsControlPressed(0, Config.Button.SetGps) then -- G SET GPS
                    aperto = false
                    SetNuiFocus(false, false)
                    SendNUIMessage({
                        open = false
                    })
                    SetNewWaypoint(cordinatechiamata)
                elseif IsControlPressed(0, Config.Button.SetMouse) then  -- F MOUSE
                    SetNuiFocus(true, true)
                elseif IsControlPressed(0, Config.Button.CloseNui) then -- Z CLOSE
                    aperto = false
                    SetNuiFocus(false, false)
                    SendNUIMessage({
                        open = false
                    })
                end
            end
        end)
    elseif aperto then
        aperto = false
        SetNuiFocus(false, false)
        SendNUIMessage({
            open = false
        })
    end
end)

RegisterNUICallback('azioni', function(data)
    if data.action == 'gps' then
        aperto = false
        SetNuiFocus(false, false)
        SendNUIMessage({
            open = false
        })
        SetNewWaypoint(cordinatechiamata)
    elseif data.action == 'close' then
        aperto = false
        SetNuiFocus(false, false)
        SendNUIMessage({
            open = false
        })
    elseif data.action == 'mouse' then
        SetNuiFocus(true, true)
    end
end)

