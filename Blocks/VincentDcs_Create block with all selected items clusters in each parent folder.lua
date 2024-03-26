-- @description Create block with all selected items clusters in each parent folder
-- @author VincentDcs
-- @version 1.0
-- @changelog initial release
-- @about Create multiple groups from selected media items clusters with note item named from parent track
--  in every parent folder

------------------------------------------------------------------------------------------------------------

-- SORT VALUES FUNCTION --
function sort_on_values(t,...)
  local a = {...}
  table.sort(t, function (u,v)
    for i in pairs(a) do
      if u[a[i]] > v[a[i]] then return false end
      if u[a[i]] < v[a[i]] then return true end
    end
  end)
end

------------------------------------------------------------------------------------------------------------

-- VARIABLES SETUP AT SCRIPT START --
function setupVariables()
    if interVal == 0 then interVal = 0.0000001 end
    
    sel_item_count = reaper.CountSelectedMediaItems(0)
    if sel_item_count == 0 then
        reaper.MB("No item selection", "Error", 0)
    end
    
    -- Add selected items to table and sort by start position --
    sel_item_Tab = {}
        
    for i = 1, sel_item_count do
        local sel_item = reaper.GetSelectedMediaItem(0, i-1)
        sel_item_Tab[i] = { item = sel_item, item_start = reaper.GetMediaItemInfo_Value(sel_item, "D_POSITION") }
    end
    reaper.Main_OnCommand(40289, 0)
    sort_on_values(sel_item_Tab, "item_start")
end
------------------------------------------------------------------------------------------------------------

-- CHECK IF NAME IS UNIQUE IN TAB --
function CheckForNameInTab(name, tab, index)
    for i in pairs(tab) do
        if i ~= index and name == tab[i] then
            if tab[name] == nil then
                tab[name] = {}
            end
            tab[name][i] = item
        end
    end
end

------------------------------------------------------------------------------------------------------------

-- CREATE TEXT ITEMS --
function CreateTextItem(track, position, end_position, name, numbering)
  
    local item = reaper.AddMediaItemToTrack(track)
    
    if numbering < 10 then
        name = name.."_0"..tostring(numbering)
    else
        name = name.."_"..tostring(numbering)
    end
    
    _, _ = reaper.GetSetMediaItemInfo_String(item, "P_NOTES", name, true )
    reaper.SetMediaItemInfo_Value(item, "D_POSITION", position)
    length = end_position - position
    reaper.SetMediaItemInfo_Value(item, "D_LENGTH", length)
    
    reaper.SetMediaItemSelected(item, true)
    
    reaper.Main_OnCommand(40032, 0) -- Group selected items
    reaper.Main_OnCommand(40289, 0) -- Unselect all items
    
    return item

end

------------------------------------------------------------------------------------------------------------

-- Sort all items in different folder tabs for each parent track --
function sortItemsInFolderTab()

    folderTab = {}

    for i = 1, #sel_item_Tab do
        local itemTrack =  reaper.GetMediaItemTrack(sel_item_Tab[i].item)
        local parentTrack = reaper.GetParentTrack(itemTrack)
        
        -- Create parentTrack Tab for each parent track in folderTab --
        if parentTrack ~= nil and folderTab[parentTrack] == nil then
            folderTab[parentTrack] = {}
            table.insert(folderTab[parentTrack], sel_item_Tab[i].item)
        elseif parentTrack ~= nil and folderTab[parentTrack] ~= nil then
            table.insert(folderTab[parentTrack], sel_item_Tab[i].item)
        end
    end
    
    for i in pairs(folderTab) do
        --reaper.SetTrackSelected(i, true)
        first_start = reaper.GetMediaItemInfo_Value(folderTab[i][1], "D_POSITION")
        prev_end = first_start + reaper.GetMediaItemInfo_Value(folderTab[i][1], "D_LENGTH")
        
        _, trackName = reaper.GetTrackName(i)
        numName = 0
        
        for j in ipairs(folderTab[i]) do
            ----
            local interVal = 0.0000001

            local cur_item = folderTab[i][j]
            local cur_start = reaper.GetMediaItemInfo_Value(cur_item, "D_POSITION")
            local cur_end = cur_start + reaper.GetMediaItemInfo_Value(cur_item, "D_LENGTH")
            
            if prev_end + interVal < cur_start then
                -- reaper.ShowConsoleMsg("\nCluster "..": "..tostring(first_start))
                numName = numName + 1
                CreateTextItem(i, first_start, prev_end, trackName, numName)
                first_start = cur_start
            end
            
            reaper.SetMediaItemSelected(cur_item, true)
            
            if j == #folderTab[i] then
                if prev_end > cur_end then
                    last_end = prev_end
                else
                    last_end = cur_end
                end
                
                -- reaper.ShowConsoleMsg("\nLast: "..tostring(first_start).." : "..tostring(#folderTab[i]))
                numName = numName + 1
                CreateTextItem(i, first_start, last_end, trackName, numName)
            end

            if prev_end > cur_end then
                -- nothing
            else
                prev_end = cur_end
            end
            ----
        end
    end
end

------------------------------------------------------------------------------------------------------------

---MAIN---

reaper.PreventUIRefresh(1)
reaper.Undo_BeginBlock()
setupVariables()
sortItemsInFolderTab()
reaper.Undo_EndBlock("Create block with all selected items clusters in each parent folder", -1)
reaper.PreventUIRefresh(-1)
reaper.UpdateArrange()
