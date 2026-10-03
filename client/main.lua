local menuOpen = false
local currentCase = nil

local function notify(msg, typ)
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(msg)
    EndTextCommandThefeedPostTicker(false, false)
end

RegisterNetEvent('x_evidence:client:notify', function(msg, typ) notify(msg, typ) end)

RegisterCommand(Config.Command, function()
    TriggerServerEvent('x_evidence:server:getCases')
end)

RegisterKeyMapping(Config.Command, 'Open X Evidence', 'keyboard', 'F7')

RegisterNetEvent('x_evidence:client:cases', function(cases)
    menuOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'open', cases = cases, types = Config.EvidenceTypes })
end)

RegisterNetEvent('x_evidence:client:caseCreated', function(id)
    notify(('Case #%s created.'):format(id), 'success')
    TriggerServerEvent('x_evidence:server:getCases')
end)

RegisterNetEvent('x_evidence:client:evidenceAdded', function(id)
    notify(('Evidence #%s logged.'):format(id), 'success')
    if currentCase then TriggerServerEvent('x_evidence:server:getCase', currentCase) end
end)

RegisterNetEvent('x_evidence:client:sceneCreated', function(id)
    notify(('Crime scene #%s registered.'):format(id), 'success')
end)

RegisterNetEvent('x_evidence:client:caseData', function(caseRow, items, scenes)
    currentCase = caseRow.id
    SendNUIMessage({ action = 'case', caseData = caseRow, evidence = items, scenes = scenes })
end)

RegisterNUICallback('close', function(_, cb)
    menuOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({action='close'})
    cb('ok')
end)

RegisterNUICallback('case', function(data, cb)
    currentCase = tonumber(data.id)
    TriggerServerEvent('x_evidence:server:getCase', currentCase)
    cb('ok')
end)

RegisterNUICallback('createCase', function(data, cb)
    TriggerServerEvent('x_evidence:server:createCase', data)
    cb('ok')
end)

RegisterNUICallback('addEvidence', function(data, cb)
    TriggerServerEvent('x_evidence:server:addEvidence', data)
    cb('ok')
end)

RegisterNUICallback('createScene', function(data, cb)
    TriggerServerEvent('x_evidence:server:createScene', data)
    cb('ok')
end)

RegisterNUICallback('status', function(data, cb)
    TriggerServerEvent('x_evidence:server:updateCaseStatus', data.id, data.status)
    cb('ok')
end)
