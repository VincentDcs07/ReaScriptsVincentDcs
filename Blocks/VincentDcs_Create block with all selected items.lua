-- @description Create a group of items with empty media item name
-- @author VincentDcs
-- @version 1.0
-- @changelog initial release
-- @about Create a group of items with empty media item name

------------------------------------------------------------------------------------------------------------

function createBlockWithAllSelectedItems()
    -- Get selected media items number
    local itemCount = reaper.CountSelectedMediaItems(0)

    -- Check if one item is selected
    if itemCount == 0 then
        -- reaper.ShowMessageBox("No item selected.", "Error", 0)
        return
    end

    -- Get start and end point of selected items
    local startOffset = reaper.GetMediaItemInfo_Value(reaper.GetSelectedMediaItem(0, 0), "D_POSITION")
    local endOffset = reaper.GetMediaItemInfo_Value(reaper.GetSelectedMediaItem(0, itemCount - 1), "D_POSITION") +
                      reaper.GetMediaItemInfo_Value(reaper.GetSelectedMediaItem(0, itemCount - 1), "D_LENGTH")
    
    local maxEndPosition = 0

    -- Check maximum position for selected items
    for i = 0, itemCount - 1 do
        local item = reaper.GetSelectedMediaItem(0, i)
        local endPosition = reaper.GetMediaItemInfo_Value(item, "D_POSITION") + reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
        
        if endPosition > maxEndPosition then
            maxEndPosition = endPosition
        end
    end
    
    -- Get first track of selected items
    local track = reaper.GetMediaItem_Track(reaper.GetSelectedMediaItem(0, 0))

    -- Get parent track
    local parentFolder = reaper.GetParentTrack(track)
    reaper.SetTrackSelected(parentFolder, true)
    
    _, parentFolderName = reaper.GetTrackName(parentFolder)
    
    if parentFolder == nil then
        reaper.ShowMessageBox("Selected items tracks are not in a folder.", "Warning", 0)
    elseif
        reaper.GetMediaTrackInfo_Value(parentFolder, "I_FOLDERDEPTH") == 1 then
        -- Récupérer le nom du dossier parent
        local _, folderName = reaper.GetSetMediaTrackInfo_String(parentFolder, "P_NAME", "", false)
    end
    
    -- Create empty track above first item
    local newTrackIndex = reaper.GetMediaTrackInfo_Value(track, "IP_TRACKNUMBER") - 1
    local newTrack = reaper.InsertTrackAtIndex(newTrackIndex, true)
    
    -- Get new track index
    local itemTrack = reaper.GetTrack(0, newTrackIndex)

    -- Create empty media item on track above with parent name
    local emptyItem = reaper.AddMediaItemToTrack(itemTrack, startPosition)
    reaper.GetSetMediaItemInfo_String(emptyItem, "P_NOTES", parentFolderName, 1)
    
    -- Set selected tracks children to same color
    reaper.Main_OnCommand(reaper.NamedCommandLookup("_SWS_COLCHILDREN"), 0)
    reaper.SetTrackSelected(parentFolder, false)

    -- Empty media item lenght
    reaper.SetMediaItemInfo_Value(emptyItem, "D_LENGTH", maxEndPosition - startOffset)
    reaper.SetMediaItemInfo_Value(emptyItem, "D_POSITION", startOffset)
    reaper.SetMediaItemSelected(emptyItem, 1)
    
    -- Group items
    reaper.Main_OnCommand(40032, 0)
end

-- MAIN --

reaper.PreventUIRefresh(1)
reaper.Undo_BeginBlock()
createBlockWithAllSelectedItems()
reaper.Undo_EndBlock("Create block with all selected items clusters", 0)
reaper.PreventUIRefresh(-1)
reaper.UpdateArrange()
