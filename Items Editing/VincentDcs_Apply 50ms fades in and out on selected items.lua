-- @description Apply 50ms fade in and fade out to all selected items
-- @author VincentDcs
-- @version 1.0
-- @changelog initial release
-- @about Applies a 50ms fade in and fade out to all selected items

function main()

  selected_items_count = reaper.CountSelectedMediaItems(0)
  Fadeval = 0.05
  
  for i = 0, selected_items_count - 1 do
      item = reaper.GetSelectedMediaItem( 0, i )
      reaper.SetMediaItemInfo_Value( item, "D_FADEINLEN", Fadeval)
      reaper.SetMediaItemInfo_Value( item, "D_FADEOUTLEN", Fadeval)
  end
end

--- MAIN FUNCTION EXE ---
reaper.PreventUIRefresh(1)
reaper.Undo_BeginBlock( "" , 0 )
main()
reaper.Undo_EndBlock( "Apply 50ms fade in and fade out to all selected media items", 0 )
reaper.PreventUIRefresh(-1)
reaper.UpdateArrange()
