dofile_once("data/scripts/gun/gun_enums.lua");
dofile_once("data/scripts/gun/gun_extra_modifiers.lua");
dofile_once("data/scripts/gun/gunaction_generated.lua");
dofile_once("data/scripts/gun/gunshoteffects_generated.lua");
dofile_once("data/scripts/gun/gun_actions.lua");

function load_actions_by_id()
	local out_table = {};

	for curr_idx, curr_action in ipairs(actions) do
		local a_id = curr_action.id;
		out_table[a_id] = curr_action;
		out_table[a_id].c = {};
		out_table[a_id].actions_index = curr_idx;
		-- out_table[curr_action.id].c = extract_action_stats(curr_action); -- Simulating spells causes thread(?) close
	end
	return out_table;
end

actions_by_id = load_actions_by_id();
