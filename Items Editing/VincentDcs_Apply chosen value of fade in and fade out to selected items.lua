-- @description Apply fade in and fade out to all selected items with chosen value
-- @author VincentDcs
-- @version 1.0
-- @changelog initial release
-- @about 
--  This script apply a fade in and fade out to all selected items with a chosen value in gui

-- GET INPUTS FROM USER --
function inputDatas()
    defaultData = "0.05"
    isNotCanceled, retvals_csv = reaper.GetUserInputs("Fades Lenght", 1, "Fades Lenght (s) =", defaultData)
    if isNotCanceled == true then
        Fadeval = tonumber(retvals_csv:match("(.+)"))
    end
end

function main()

  selected_items_count = reaper.CountSelectedMediaItems(0)
  if selected_items_count ~= 0 then
    inputDatas()
    if Fadeval > 3600 then
        reaper.MB ("Please select a numbre below 3600", "Error", 0)
    else
        for i = 0, selected_items_count - 1 do
            item = reaper.GetSelectedMediaItem( 0, i )
            reaper.SetMediaItemInfo_Value( item, "D_FADEINLEN", Fadeval)
            reaper.SetMediaItemInfo_Value( item, "D_FADEOUTLEN", Fadeval)
        end
    end
  else
    reaper.MB ("Please select at least one item.", "No item selected", 0)
  end
end

--- MAIN FUNCTION EXE ---
reaper.PreventUIRefresh(1)
reaper.Undo_BeginBlock( "" , 0 )
main()
reaper.Undo_EndBlock( "Apply fade in and fade out to all selected media items woth chosen value", 0 )
reaper.PreventUIRefresh(-1)
reaper.UpdateArrange()
