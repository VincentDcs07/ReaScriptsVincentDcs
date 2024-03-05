-- @author VincentDcs 
-- @version 1.0
-- Unselect all items on collapsed tracks

------------------------------------------------------------------------------------------------------------

function selectCollapsedTrack()
    reaper.Main_OnCommand(40297, 0) -- Unselect all tracks
    
    for i = 0, reaper.CountTracks(0) - 1 do
        track = reaper.GetTrack(0 , i)
        trackState = reaper.GetMediaTrackInfo_Value(track , "I_FOLDERCOMPACT")
        
        if trackState == 2 then
           reaper.SetTrackSelected(track, true)
        end
    end
end

------------------------------------------------------------------------------------------------------------

function SelectChildrenOfSelectedParentTrack()
    for i = 0, reaper.CountSelectedTracks(0) - 1 do
        numSelectedTracks = reaper.CountSelectedTracks(0)

        for j = 0, numSelectedTracks - 1 do
            parentTrack = reaper.GetSelectedTrack(0, j)
            
            if parentTrack ~= nil then
               numTracks = reaper.CountTracks(0)
                
                for k = 0, numTracks - 1 do
                    childTrack = reaper.GetTrack(0, k)
                    
                    if reaper.GetParentTrack(childTrack) == parentTrack then
                       reaper.SetTrackSelected(childTrack, true)
                    end
                end
            end
        end
    end
end

------------------------------------------------------------------------------------------------------------

function UnselectItemsOnSelectedTracks()

    numTracksSelected = reaper.CountSelectedTracks(0)
    for i = 0, numTracksSelected - 1 do
        track = reaper.GetSelectedTrack(0 , i)
        numItems =  reaper.CountTrackMediaItems(track)
        
        for j = 0, numItems - 1 do
            item = reaper.GetTrackMediaItem(track, j)
            reaper.SetMediaItemSelected(item, false)
        end
    end
end

--------------------------------------------------MAIN------------------------------------------------------

reaper.PreventUIRefresh(1)
reaper.Undo_BeginBlock()
selectCollapsedTrack()
SelectChildrenOfSelectedParentTrack()
UnselectItemsOnSelectedTracks()
reaper.Main_OnCommand(40297, 0) -- Unselect all tracks
reaper.Undo_EndBlock("Unselect all items on collapsed tracks", 0)
reaper.PreventUIRefresh(-1)
reaper.UpdateArrange()
