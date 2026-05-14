local QBCore = exports['qb-core']:GetCoreObject()
local cam = nil
local charPed = nil

-- Koordinatlar (GÜNCELLENDİ)
local PedCoords = vector4(-745.55, -1507.20, 5.00, 18.58) 
local CamCoords = vector4(-747.21, -1503.52, 5.00, 199.69)

-- Temizlik Fonksiyonu
local function cleanup()
    if charPed then DeletePed(charPed) charPed = nil end
    if cam then 
        RenderScriptCams(false, false, 0, true, true)
        DestroyCam(cam, false)
        cam = nil
    end
    DisplayRadar(true)
    ClearTimecycleModifier()
end

-- Sunucuya girince otomatik başlat
CreateThread(function()
	while true do
		Wait(0)
		if NetworkIsSessionStarted() then
			TriggerEvent('thd_multichar:client:open')
			return
		end
	end
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    ShutdownLoadingScreenNui()
    cleanup()
    -- FadeIn artık spawn eventinde yapılıyor
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    DoScreenFadeOut(500)
    Wait(1000)
    TriggerEvent('thd_multichar:client:open')
end)

-- Yeni Spawn Eventi (Sunucudan gelen son konuma ışınlar)
RegisterNetEvent('thd_multichar:client:spawn', function(coords)
    local ped = PlayerPedId()
    SetEntityCoords(ped, coords.x, coords.y, coords.z)
    SetEntityHeading(ped, coords.w)
    FreezeEntityPosition(ped, false)
    
    DoScreenFadeIn(1000)
end)

RegisterNetEvent('thd_multichar:client:open', function()
    -- BLUR KALDIRILDI
    -- SetTimecycleModifier('hud_def_blur')
    -- SetTimecycleModifierStrength(1.0)
    FreezeEntityPosition(PlayerPedId(), true)
    
    -- Harita Yüklenme Beklemesi (Request 3)
    Wait(2500)

    DisplayRadar(false)

    -- Kamera Kurulumu
    DoScreenFadeIn(500)
    if cam then DestroyCam(cam, false) end
    cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", CamCoords.x, CamCoords.y, CamCoords.z, 0.0, 0.0, CamCoords.w, 50.00, false, 0)
    PointCamAtCoord(cam, PedCoords.x, PedCoords.y, PedCoords.z + 0.5)
    SetCamActive(cam, true)
    RenderScriptCams(true, false, 1, true, true)
    
    -- UI Yüklenirken Loading screen'i kaldır
    ShutdownLoadingScreenNui()

    -- ÖNCE veriyi çekiyoruz
    QBCore.Functions.TriggerCallback('thd_multichar:server:getChars', function(result)
        -- Karakter datası geldi, UI'ya gönder
        SendNUIMessage({
            action = "open",
            characters = result,
            maxSlots = 4
        })
        
        -- MOUSE FOCUS FIX: Biraz bekleyip focus veriyoruz ki UI hazır olsun
        SetNuiFocus(true, true)
        
        -- Failsafe: Eğer ilk seferde işlemezse diye
        CreateThread(function()
            Wait(100)
            SetNuiFocus(true, true)
        end)
    end)
end)

RegisterNUICallback('previewCharacter', function(data)
    local charData = data.charData
    
    if charPed then DeletePed(charPed) charPed = nil end
    if not charData then return end -- Boş slot ise çık

    local model = charData.model or "mp_m_freemode_01"
    if tonumber(model) then model = tonumber(model) end

    RequestModel(model)
    while not HasModelLoaded(model) do Wait(0) end

    charPed = CreatePed(2, model, PedCoords.x, PedCoords.y, PedCoords.z - 0.98, PedCoords.w, false, true)
    SetPedComponentVariation(charPed, 0, 0, 0, 2)
    FreezeEntityPosition(charPed, true)
    SetEntityInvincible(charPed, true)
    PlaceObjectOnGroundProperly(charPed)
    SetBlockingOfNonTemporaryEvents(charPed, true)

    -- Kıyafet Giydirme (illenium-appearance uyarlaması)
    if charData.skin then
        -- Eğer sunucuda illenium-appearance varsa export kullan
        if GetResourceState('illenium-appearance') == 'started' then
             exports['illenium-appearance']:setPedAppearance(charPed, charData.skin)
        else
            -- Yoksa klasik qb-clothing eventini dene
            TriggerEvent('qb-clothing:client:loadPlayerClothing', charData.skin, charPed)
        end
    end
end)

RegisterNUICallback('selectCharacter', function(data)
    local cids = data.cids
    DoScreenFadeOut(500)
    Wait(500)
    cleanup()
    SetNuiFocus(false, false)
    SendNUIMessage({ action = "close" })
    TriggerServerEvent('thd_multichar:server:loadUserData', cids)
end)

RegisterNUICallback('createCharacter', function(data)
    local slot = data.cid or 1
    DoScreenFadeOut(500)
    Wait(500)
    if charPed then DeletePed(charPed) charPed = nil end
    SetNuiFocus(false, false)
    SendNUIMessage({ action = "close" })
    TriggerEvent('thd_identity:showRegisterScreen', { cid = slot })
    Wait(500)
    DoScreenFadeIn(1000)
end)