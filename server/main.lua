local QBCore = exports['qb-core']:GetCoreObject()

-- 1. Karakterleri ve Skinleri Çekme (CALLBACK) - ROBUST REWRITE
QBCore.Functions.CreateCallback('thd_multichar:server:getChars', function(source, cb)
    local src = source
    local license = QBCore.Functions.GetIdentifier(src, 'license')

    print('^3[THD Multichar] ^7Fetching characters for License: ' .. tostring(license))

    -- Adım 1: Lisansa ait tüm karakterleri çek
    -- Senkronize şekilde bekle
    local result = MySQL.query.await('SELECT * FROM players WHERE license = ? ORDER BY cid ASC', {license})
    local characters = {}

    if result and #result > 0 then
        print('^3[THD Multichar] ^7Found ' .. #result .. ' characters.')
        for i = 1, #result do
            local char = result[i]
            local cid = tonumber(char.cid) -- Slot numarası

            if cid then
                 -- Güvenli JSON Decode (Hata verirse patlamasın)
                local function safeDecode(data)
                    if not data then return nil end
                    local success, decoded = pcall(json.decode, data)
                    if success then return decoded else return nil end
                end

                char.charinfo = safeDecode(char.charinfo)
                char.money = safeDecode(char.money)
                char.job = safeDecode(char.job)

                -- Adım 2: Skin/Kıyafet Verisini Çek
                local skinData = MySQL.query.await('SELECT * FROM playerskins WHERE citizenid = ? AND active = 1', {char.citizenid})

                if skinData and skinData[1] then
                    char.skin = safeDecode(skinData[1].skin)
                    char.model = skinData[1].model
                else
                    char.skin = nil
                    char.model = "mp_m_freemode_01" -- Varsayılan
                end

                -- Karakteri slot numarasına (cid) göre tabloya ekle
                -- STRING key kullanarak JSON Object olmaya zorluyoruz (Array değil)
                -- Bu sayede JS tarafındaki index kayması (0 vs 1) düzelir.
                characters[tostring(cid)] = char
                print('^2[THD Multichar] ^7Loaded character slot: ' .. cid)
            else
                print('^1[THD Multichar] ^7Skipping character with invalid CID.')
            end
        end
    else
        print('^3[THD Multichar] ^7No characters found for this license.')
    end

    -- İstemciye (Client) gönder
    cb(characters)
end)

-- 2. Karakter Seçimi ve Oyuna Giriş
RegisterNetEvent('thd_multichar:server:loadUserData', function(cids)
    local src = source
    local citizenid = cids
    
    if citizenid then
        local loginSuccess = QBCore.Player.Login(src, citizenid)
        if loginSuccess then
            print('^2[THD Multichar] ^7Login successful: ' .. citizenid)
            TriggerClientEvent('QBCore:Client:OnPlayerLoaded', src)
            
            -- Oyuncuyu doğru bucket'a al
            SetPlayerRoutingBucket(src, 0) 
            
            -- Son konuma ışınla (User isteği)
            local Player = QBCore.Functions.GetPlayer(src)
            if Player and Player.PlayerData.position then
                TriggerClientEvent('thd_multichar:client:spawn', src, Player.PlayerData.position)
            end
        end
    end
end)

-- 3. Logout Komutu (Karakter Seçme Ekranına Dönüş)
QBCore.Commands.Add('logout', 'Karakter seçme ekranına dön', {}, false, function(source)
    local src = source
    QBCore.Player.Logout(src)
    print('^2[THD Multichar] ^7Player logged out: ' .. src)
end)