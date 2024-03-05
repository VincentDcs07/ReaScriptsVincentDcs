-- @description Create a group of items with empty media item name
-- @author VincentDcs
-- @version 1.0
-- @changelog initial release
-- @about Create a group of items with empty media item name

------------------------------------------------------------------------------------------------------------

-- CREATE TEXT ITEMS -- Credit to X-Raym
function CreateTextItem(track, position, length)

  local item = reaper.AddMediaItemToTrack(track)

  reaper.SetMediaItemInfo_Value(item, "D_POSITION", position)
  reaper.SetMediaItemInfo_Value(item, "D_LENGTH", length)
  
  return item

end

------------------------------------------------------------------------------------------------------------

-- TABLE INIT -- Credit to X-Raym
local setSelectedMediaItem = {}

-- CREATE NOTE ITEMS -- Credit to X-Raym
function createNoteItems()

  selected_tracks_count = reaper.CountSelectedTracks(0)

  if selected_tracks_count > 0 then

    -- DEFINE TRACK DESTINATION
    selected_track = reaper.GetSelectedTrack(0,0)

    -- COUNT SELECTED ITEMS
    selected_items_count = reaper.CountSelectedMediaItems(0)

    if selected_items_count > 0 then

      -- SAVE TAKES SELECTION
      for j = 0, selected_items_count - 1  do
        setSelectedMediaItem[j] = reaper.GetSelectedMediaItem(0, j)
      end

      -- LOOP THROUGH TAKE SELECTION
      for i = 0, selected_items_count - 1  do
        -- GET ITEMS AND TAKES AND PARENT TRACK --
        item = setSelectedMediaItem[i] -- Get selected item i

        -- TIMES
        item_start = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
        item_duration = reaper.GetMediaItemInfo_Value(item, "D_LENGTH")

        -- ACTION
        CreateTextItem(selected_track, item_start, item_duration)
        
      end -- ENDLOOP through selected items
      reaper.Main_OnCommand(40421, 0)
    else -- No selected item
      reaper.ShowMessageBox("Select at least one item","Please",0)
    end -- If select item
  else -- No selected track
    reaper.ShowMessageBox("The script met an error when trying to acces created track for note items","Error",0)
  end -- if selected track
end


------------------------------------------------------------------------------------------------------------

-- SETUP ALL VARIABLES FOR CLUSTERS --
function setupVariables()
    
    selected_items_count = reaper.CountSelectedMediaItems(0)
    
    first_item = reaper.GetSelectedMediaItem(0, 0)
    
    first_item_start_pos = reaper.GetMediaItemInfo_Value(first_item, "D_POSITION")
    
    prev_item_end_pos = first_item_start_pos
    
    -- Get first track of selected items
    track = reaper.GetMediaItem_Track(first_item)
    
    -- Get track info value
    newTrackIndex = reaper.GetMediaTrackInfo_Value(track, "IP_TRACKNUMBER")-1
    
    -- Get new track index
    itemTrack = reaper.GetTrack(0, newTrackIndex)
    
end
------------------------------------------------------------------------------------------------------

-- CREATE REGION FOR CLUSTERS --
function createItemsGroup()

    setupVariables()
    
    itemTab = {}
    groupTab = {}
    
    for i = 1, selected_items_count do
        itemTab[i] = reaper.GetSelectedMediaItem(0, i)
    end
    
    for i = 0, selected_items_count - 1 do
        cur_item = reaper.GetSelectedMediaItem(0, i)
        
        cur_item_start_pos = reaper.GetMediaItemInfo_Value(cur_item, "D_POSITION")
        cur_item_end_pos = cur_item_start_pos + reaper.GetMediaItemInfo_Value(cur_item, "D_LENGTH")
        
        if prev_item_end_pos + 0.000001 < cur_item_start_pos then
           ---
           -- Create empty media item on track above
           emptyItem = reaper.AddMediaItemToTrack(itemTrack)
           
           -- Empty media item lenght
           reaper.SetMediaItemInfo_Value(emptyItem, "D_LENGTH", prev_item_end_pos - first_item_start_pos)
           reaper.SetMediaItemInfo_Value(emptyItem, "D_POSITION", first_item_start_pos)
           ---
           
           groupTab[i] = emptyItem
           
           first_item_start_pos = cur_item_start_pos
        end
            
        if i == selected_items_count - 1 then
            if prev_item_end_pos > cur_item_end_pos then
                last_item_end_pos = prev_item_end_pos
            else
                last_item_end_pos = cur_item_end_pos
            end
            
            -- Create empty media item on track above
            emptyItem = reaper.AddMediaItemToTrack(itemTrack)
            
            -- Empty media item lenght
            reaper.SetMediaItemInfo_Value(emptyItem, "D_LENGTH", last_item_end_pos - first_item_start_pos)
            reaper.SetMediaItemInfo_Value(emptyItem, "D_POSITION", first_item_start_pos)
            
            groupTab[i] = emptyItem
        end
        
        if prev_item_end_pos > cur_item_end_pos then
            --nothing
        else
            prev_item_end_pos = cur_item_end_pos
        end
    end
end

function deleteItemTab()
    reaper.DeleteTrackMediaItem(itemTrack, reaper.GetSelectedMediaItem(0, 0))
    for i in pairs(itemTab) do
        --reaper.Main_OnCommand(40289, 0) -- Clear selection of item
        reaper.DeleteTrackMediaItem(itemTrack, itemTab[i])
    end
end


------------------------------------------------------------------------------------------------------------

function createBlockTrack()
    
    -- Get first track of selected items
    local track = reaper.GetMediaItem_Track(reaper.GetSelectedMediaItem(0, 0))
    
    -- Get parent track
    local parentFolder = reaper.GetParentTrack(track)
    
    
    _, parentFolderName = reaper.GetTrackName(parentFolder)
    reaper.Main_OnCommand(40297, 0) -- Unselect all tracks
    reaper.SetTrackSelected(parentFolder, true)

    if parentFolder == nil then
        reaper.ShowMessageBox("Selected items tracks are not in a folder.", "Warning", 0)
    elseif
        reaper.GetMediaTrackInfo_Value(parentFolder, "I_FOLDERDEPTH") == 1 then
        -- Get parent folder name
        local _, folderName = reaper.GetSetMediaTrackInfo_String(parentFolder, "P_NAME", "", false)
    end
end

------------------------------------------------------------------------------------------------------------

function createBlockWithAllSelectedItems()
    for i in pairs(groupTab) do
        reaper.SetMediaItemSelected(groupTab[i], true)
        reaper.Main_OnCommand(40290, 0) -- Set time selection to items
        reaper.Main_OnCommand(40717, 0) -- Select all items in time selection
        -- Group items
        reaper.Main_OnCommand(40032, 0)
        reaper.Main_OnCommand(40289, 0) -- Unselect all items
        reaper.Main_OnCommand(40635, 0) -- Clear time selection
    end
end

------------------------------------------------------------------------------------------------------------

---MAIN---

reaper.PreventUIRefresh(1)
reaper.Undo_BeginBlock()
createBlockTrack()
createNoteItems()
createItemsGroup()
deleteItemTab()
createBlockWithAllSelectedItems()
reaper.Undo_EndBlock("Create block with all selected items clusters", 0)
reaper.PreventUIRefresh(-1)
reaper.UpdateArrange()
