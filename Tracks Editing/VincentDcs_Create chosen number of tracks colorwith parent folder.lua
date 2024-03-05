-- Create track
 
-- Display GUI for user input, tracks, color, name
function getUserInput()
    local retval, inputs = reaper.GetUserInputs("Create Tracks", 2, "Tracks number : ,Parent Track name : ", "")
    if retval then
        local tracksNum, trackName = inputs:match("([^,]+),([^,]+)")
        numberOfTracks = math.tointeger(tracksNum)
        nameParentTrack = tostring(trackName)
    else
        return nil
    end
end

function createTracks()
    if numberOfTracks then
        reaper.InsertTrackAtIndex( 0, 1)
        firstTrack = reaper.GetTrack( 0, 0)
        --reaper.Main_OnCommand(40297, 0)
        -- Loop creating tracks
        for i = 1, numberOfTracks do
            reaper.InsertTrackAtIndex( i, 1)
           -- reaper.Main_OnCommand(40297, 0)
            lastTrack = reaper.GetTrack(0, i)
        end
        reaper.SetMediaTrackInfo_Value( lastTrack, "I_FOLDERDEPTH", -1 )
        reaper.SetMediaTrackInfo_Value( firstTrack, "I_FOLDERDEPTH", 1 )
        reaper.GetSetMediaTrackInfo_String( firstTrack, "P_NAME", nameParentTrack, 1 )
    end
end

reaper.PreventUIRefresh(1)
reaper.Undo_BeginBlock()
getUserInput()
createTracks()
reaper.Undo_EndBlock("Create tracks with parent", 0)
reaper.PreventUIRefresh(-1)
reaper.UpdateArrange()
