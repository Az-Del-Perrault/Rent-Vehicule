

local OpenRental = false 
MenuRental = RageUI.CreateMenu("Location", "Vehicule Disponible")
MenuRental:SetRectangleBanner(0, 0, 0, 0)
MenuRental.Closed = function()
    OpenRental = false 
end

local function getPaymentOptions()
    return {
        { value = 'liquide', label = 'Liquide' },
        { value = 'banque', label = 'Banque' }
    }
end

local Lock = true

function OpenMenuRental(Type)
    if OpenRental then 
        OpenRental = false 
        RageUI.Visible(MenuRental, false)
        return
    else
        OpenRental = true 
        RageUI.Visible(MenuRental, true)
        CreateThread(function()
            while OpenRental do 
                FreezeEntityPosition(PlayerPedId(), true)
                RageUI.IsVisible(MenuRental, function()
                    local typeLocations = nil

                    if Type.Type == "Vehicle" then
                        typeLocations = Location.Vehicle
                    elseif Type.Type == "Bateau" then
                        typeLocations = Location.Bateau
                    elseif Type.Type == "Helico" then
                        typeLocations = Location.Helico
                    elseif Type.Type == "Avion" then
                        typeLocations = Location.Avion
                    end

                    if typeLocations then
                        for k,v in pairs(typeLocations) do 
                            RageUI.Button(v.Label, nil, {RightLabel = "~g~"..v.Prix.."$~s~ →"}, Lock, {
                                onSelected = function()
                                    local paymentOptions = getPaymentOptions()
                            
                                    local input = lib.inputDialog('Choix du paiement', {
                                        { type = 'select', label = 'Sélectionnez votre méthode de paiement', required = true, options = paymentOptions }
                                    })
                            
                                    if input and input[1] then
                            
                                        TriggerServerEvent("BuyVehicle", v.Name, v.Prix, Type.Type, v.SpawnVehicle, v.Label, input[1])
                            
                                        RageUI.CloseAll()
                                        OpenRental = false 
                                        Lock = false
                                        Wait(1000)  
                                        Lock = true
                                    end
                                end
                            })
                        end
                    end
                end)
                Wait(1)
            end
            FreezeEntityPosition(PlayerPedId(), false)
        end)
    end
end

CreateThread(function()
    -- Pré-chargement des blips et des pédés
    for k, v in pairs(Location.Point) do 
        -- Création des blips
        local blip = AddBlipForCoord(v.Pos)
        SetBlipSprite(blip, v.Blip)
        SetBlipScale(blip, v.ScaleBlip)
        SetBlipColour(blip, v.BlipColor)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(v.BlipText)
        EndTextCommandSetBlipName(blip)
    
        -- Chargement et création des pédés
        local hash = GetHashKey(v.NamePed)
        RequestModel(hash)
        while not HasModelLoaded(hash) do 
            Wait(100) -- Attendre brièvement jusqu'à ce que le modèle soit chargé
        end

        local ped = CreatePed(1, hash, v.Pos.x, v.Pos.y, v.Pos.z - 1, v.HeadingPed, false, true)
        FreezeEntityPosition(ped, true)
        SetEntityInvincible(ped, true)
        SetBlockingOfNonTemporaryEvents(ped, true)

        -- Animation du pédé
        if v.ActiveAnim then 
            TaskStartScenarioInPlace(ped, v.Animation, 0, true)
        end

        -- Déchargement du modèle pour économiser de la mémoire
        SetModelAsNoLongerNeeded(hash)

        exports["inside-interaction"]:AddInteractionCoords(vector3(v.Pos.x, v.Pos.y, v.Pos.z), { 
            checkVisibility = true,
            {
                name = "coords_" .. k,  -- Nom unique basé sur l'index
                icon = "fa-solid fa-money-bill",  -- Icône à afficher
                label = "Location",  -- Étiquette pour l'interaction
                key = "E",  -- Clé pour déclencher l'action
                duration = 1000,  -- Durée de l'interaction en millisecondes
                action = function()
                    OpenMenuRental(v)  -- Fonction à appeler lors de l'interaction
                end
            }
        })
    end
end)
