-- dofile_once( "data/scripts/lib/utilities.lua" )

function OnWorldPostUpdate() -- This is called every time the game has finished updating the world
	dofile("mods/data_test/files/actions_by_id.lua")
	GamePrint( "Post-update hook " .. tostring(GameGetFrameNum()) )
end