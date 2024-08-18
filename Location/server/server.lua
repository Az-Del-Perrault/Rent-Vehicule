ESX = exports["es_extended"]:getSharedObject()

RegisterNetEvent("BuyVehicle")
AddEventHandler("BuyVehicle", function(Name, Prix, Type, SpawnVehicle, Label, PaymentType)
    local _src = source
    local xPlayer = ESX.GetPlayerFromId(_src)
    local GetMoney = xPlayer.getMoney()
    local GetBank = xPlayer.getAccount('bank').money

    -- Debug: Log the PaymentType received
    print("PaymentType received: " .. tostring(PaymentType))

    -- Normaliser le PaymentType pour éviter les problèmes de casse
    PaymentType = string.lower(PaymentType)

    if PaymentType == "liquide" then
        if GetMoney >= Prix then
            xPlayer.removeMoney(Prix)
            TriggerClientEvent("esx:showNotification", _src, "~g~Vous venez de louer "..Label.." pour "..Prix.."$ en liquide.")
            local Vehicle = CreateVehicle(Name, SpawnVehicle, true, true)
            TaskWarpPedIntoVehicle(_src, Vehicle, -1)
        else
            TriggerClientEvent("esx:showNotification", _src, "~r~Vous n'avez pas assez d'argent liquide.")
        end

    elseif PaymentType == "banque" then
        if GetBank >= Prix then
            xPlayer.removeAccountMoney('bank', Prix)
            TriggerClientEvent("esx:showNotification", _src, "~g~Vous venez de louer "..Label.." pour "..Prix.."$ par carte bancaire.")
            local Vehicle = CreateVehicle(Name, SpawnVehicle, true, true)
            TaskWarpPedIntoVehicle(_src, Vehicle, -1)
        else
            TriggerClientEvent("esx:showNotification", _src, "~r~Vous n'avez pas assez de fonds sur votre compte bancaire.")
        end

    else
        TriggerClientEvent("esx:showNotification", _src, "~r~Type de paiement invalide.")
    end
end)

