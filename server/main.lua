local QBCore
if Config.Framework == 'qbcore' then
    QBCore = exports['qb-core']:GetCoreObject()
end

local function notify(src, msg, typ)
    TriggerClientEvent('x_evidence:client:notify', src, msg, typ or 'primary')
end

local function isPolice(src)
    if not Config.RequirePoliceJob or Config.Framework ~= 'qbcore' then return true end
    local p = QBCore.Functions.GetPlayer(src)
    if not p then return false end
    local job = p.PlayerData.job and p.PlayerData.job.name
    return job and Config.PoliceJobs[job] == true
end

local function getOfficer(src)
    if Config.Framework ~= 'qbcore' then return ('Officer %s'):format(src) end
    local p = QBCore.Functions.GetPlayer(src)
    if not p then return ('Officer %s'):format(src) end
    return p.PlayerData.charinfo and (p.PlayerData.charinfo.firstname .. ' ' .. p.PlayerData.charinfo.lastname) or ('Officer %s'):format(src)
end

CreateThread(function()
    MySQL.query([[CREATE TABLE IF NOT EXISTS x_evidence_cases (
        id INT AUTO_INCREMENT PRIMARY KEY,
        title VARCHAR(120) NOT NULL,
        status VARCHAR(30) NOT NULL DEFAULT 'open',
        lead_officer VARCHAR(120) NOT NULL,
        description TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )]])
    MySQL.query([[CREATE TABLE IF NOT EXISTS x_evidence_items (
        id INT AUTO_INCREMENT PRIMARY KEY,
        case_id INT NOT NULL,
        evidence_type VARCHAR(40) NOT NULL,
        label VARCHAR(120) NOT NULL,
        description TEXT,
        location_x DOUBLE,
        location_y DOUBLE,
        location_z DOUBLE,
        collected_by VARCHAR(120),
        collected_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        status VARCHAR(30) NOT NULL DEFAULT 'collected',
        metadata LONGTEXT
    )]])
    MySQL.query([[CREATE TABLE IF NOT EXISTS x_evidence_scenes (
        id INT AUTO_INCREMENT PRIMARY KEY,
        case_id INT NOT NULL,
        x DOUBLE NOT NULL, y DOUBLE NOT NULL, z DOUBLE NOT NULL,
        notes TEXT,
        created_by VARCHAR(120),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )]])
end)

RegisterNetEvent('x_evidence:server:createCase', function(data)
    local src = source
    if not isPolice(src) then return notify(src, 'You are not authorized.', 'error') end
    local title = tostring(data.title or 'Untitled Case'):sub(1, 120)
    local desc = tostring(data.description or ''):sub(1, 2000)
    MySQL.insert('INSERT INTO x_evidence_cases (title, lead_officer, description) VALUES (?, ?, ?)', { title, getOfficer(src), desc }, function(id)
        TriggerClientEvent('x_evidence:client:caseCreated', src, id)
    end)
end)

RegisterNetEvent('x_evidence:server:addEvidence', function(data)
    local src = source
    if not isPolice(src) then return notify(src, 'You are not authorized.', 'error') end
    if not data.caseId or not Config.EvidenceTypes[data.evidenceType] then return end
    local ped = GetPlayerPed(src)
    local coords = GetEntityCoords(ped)
    local metadata = json.encode(data.metadata or {})
    MySQL.insert('INSERT INTO x_evidence_items (case_id, evidence_type, label, description, location_x, location_y, location_z, collected_by, metadata) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)', {
        tonumber(data.caseId), data.evidenceType, tostring(data.label or Config.EvidenceTypes[data.evidenceType].label), tostring(data.description or ''), coords.x, coords.y, coords.z, getOfficer(src), metadata
    }, function(id)
        TriggerClientEvent('x_evidence:client:evidenceAdded', src, id)
    end)
end)

RegisterNetEvent('x_evidence:server:createScene', function(data)
    local src = source
    if not isPolice(src) then return notify(src, 'You are not authorized.', 'error') end
    local ped = GetPlayerPed(src)
    local c = GetEntityCoords(ped)
    MySQL.insert('INSERT INTO x_evidence_scenes (case_id, x, y, z, notes, created_by) VALUES (?, ?, ?, ?, ?, ?)', {
        tonumber(data.caseId), c.x, c.y, c.z, tostring(data.notes or ''), getOfficer(src)
    }, function(id)
        TriggerClientEvent('x_evidence:client:sceneCreated', src, id, {x=c.x,y=c.y,z=c.z})
    end)
end)

lib = lib or nil
RegisterNetEvent('x_evidence:server:getCases', function()
    local src = source
    if not isPolice(src) then return end
    MySQL.query('SELECT id, title, status, lead_officer, description, created_at FROM x_evidence_cases ORDER BY id DESC LIMIT 100', {}, function(rows)
        TriggerClientEvent('x_evidence:client:cases', src, rows or {})
    end)
end)

RegisterNetEvent('x_evidence:server:getCase', function(caseId)
    local src = source
    if not isPolice(src) then return end
    caseId = tonumber(caseId)
    if not caseId then return end
    MySQL.single('SELECT * FROM x_evidence_cases WHERE id = ?', {caseId}, function(caseRow)
        if not caseRow then return notify(src, 'Case not found.', 'error') end
        MySQL.query('SELECT * FROM x_evidence_items WHERE case_id = ? ORDER BY id DESC', {caseId}, function(items)
            MySQL.query('SELECT * FROM x_evidence_scenes WHERE case_id = ? ORDER BY id DESC', {caseId}, function(scenes)
                TriggerClientEvent('x_evidence:client:caseData', src, caseRow, items or {}, scenes or {})
            end)
        end)
    end)
end)

RegisterNetEvent('x_evidence:server:updateCaseStatus', function(caseId, status)
    local src = source
    if not isPolice(src) then return end
    if not ({open=true, suspended=true, solved=true, archived=true})[status] then return end
    MySQL.update('UPDATE x_evidence_cases SET status = ? WHERE id = ?', {status, tonumber(caseId)}, function()
        notify(src, 'Case status updated.', 'success')
    end)
end)
