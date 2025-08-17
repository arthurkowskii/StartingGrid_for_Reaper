-- Fonction pour trouver la première position libre sur une piste
local function findFirstFreePosition(track)
    local itemCount = reaper.CountTrackMediaItems(track)
    local freePosition = 0
    
    for i = 0, itemCount - 1 do
        local item = reaper.GetTrackMediaItem(track, i)
        local itemPosition = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
        local itemLength = reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
        
        if itemPosition > freePosition then
            break
        else
            freePosition = math.max(freePosition, itemPosition + itemLength)
        end
    end
    
    return freePosition
end

-- Gather
local num_items = reaper.CountSelectedMediaItems(0)
if num_items == 0 then return end

-- Table pour stocker les items par piste
local items_by_track = {}

-- Récupérer et trier
for i = 0, num_items - 1 do
    local item = reaper.GetSelectedMediaItem(0, i)
    local track = reaper.GetMediaItemTrack(item)
    
    -- Si la piste n'existe pas encore dans le tableau, l'ajouter
    if items_by_track[track] == nil then
        items_by_track[track] = {}
    end
    
    -- Ajouter l'item à la piste correspondante
    table.insert(items_by_track[track], item)
end

-- Move
for track, items in pairs(items_by_track) do
    local current_position = findFirstFreePosition(track)
    
    -- Trier les items par leur position actuelle pour éviter des problèmes d'ordre
    table.sort(items, function(a, b)
        return reaper.GetMediaItemInfo_Value(a, "D_POSITION") < reaper.GetMediaItemInfo_Value(b, "D_POSITION")
    end)
    
    -- Déplacer chaque item
    for _, item in ipairs(items) do
        reaper.SetMediaItemPosition(item, current_position, false)
        
        -- Calculer la nouvelle position pour l'item suivant
        local item_length = reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
        current_position = current_position + item_length
    end
end

-- Mettre à jour l'interface de REAPER pour refléter les changements
reaper.UpdateArrange()
