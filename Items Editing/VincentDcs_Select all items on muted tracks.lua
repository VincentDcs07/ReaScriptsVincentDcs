-- @description Select all items on muted tracks
-- @author VincentDcs
-- @version 1.0
-- @changelog initial release
-- @about
--  Select all items on muted tracks

------------------------------------------------------------------------------------------------------------

function selectMutedTrack()
    reaper.Main_OnCommand(40297, 0) -- Unselect all tracks
    reaper.Main_OnCommand(40289, 0) -- Unselect all items
    
    for i = 0, reaper.CountTracks(0) - 1 do
        trackCount = reaper.GetTrack(0 , i)
        trackMuted = reaper.GetMediaTrackInfo_Value( trackCount , "B_MUTE" )
        if trackMuted == 1 then
            reaper.SetTrackSelected(trackCount, true)
        end
    end
end

------------------------------------------------------------------------------------------------------------

function selectItemsOnSelectedMutedTracks()
    numTracksSelected = reaper.CountSelectedTracks(0)
    for i = 0, numTracksSelected - 1 do
        track = reaper.GetSelectedTrack(0 , i)
        numItems =  reaper.CountTrackMediaItems(track)
        
        for j = 0, numItems - 1 do
            item = reaper.GetTrackMediaItem(track, j)
            reaper.SetMediaItemSelected(item, true)
        end
    end
end

--------------------------------------------------MAIN------------------------------------------------------
reaper.PreventUIRefresh(1)
reaper.Undo_BeginBlock()
selectMutedTrack()
selectItemsOnSelectedMutedTracks()
reaper.Undo_EndBlock("Unselect all items on muted tracks", 0)
reaper.PreventUIRefresh(-1)
reaper.UpdateArrange()
