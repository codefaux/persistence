local _mana = 0;
local total_used_mana = 0;
local highest_used_mana = 0;
local last_mana = 0;
local deck_fired_string = "";
local called_actions = {};

function thousands_separator(amount)
    local formatted = amount;
    while true do  
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
            if (k==0) then
            break
        end
    end
    return formatted;
end

local __start_shot = _start_shot;
function _start_shot( current_mana )
    deck_fired_string = "";
    for k,v in pairs( deck ) do
        deck_fired_string = deck_fired_string..v.id..",";
    end
    shot_projectile_count = 0;
    __start_shot( current_mana );
    _mana = current_mana;
    total_used_mana = 0;
    highest_used_mana = 0;
    last_mana = 0;
end

local _register_action = register_action;
function register_action( state )
    if not reflecting then
        GlobalsSetValue( "spell_lab_last_recharge_time", tostring( current_reload_time ) );
        if ModSettingGet( "spell_lab.no_recoil" ) == true then shot_effects.recoil_knockback = 0; end
        if ModSettingGet( "spell_lab.force_fxcrit" ) == true then state.game_effect_entities = state.game_effect_entities .. "data/entities/misc/effect_apply_wet.xml,data/entities/misc/effect_apply_oiled.xml,data/entities/misc/effect_apply_on_fire.xml,data/entities/misc/effect_apply_bloody.xml,"; end
        if ModSettingGet( "spell_lab.spell_logging" ) == true then
            GamePrint( "  Projectile Damage: " .. thousands_separator(state.damage_projectile_add * 25) );
            GamePrint( "  Projectiles: " .. shot_projectile_count );
            GamePrint( "  Speed Multiplier: " .. state.speed_multiplier );
            GamePrint( "  Lifetime Add: " .. state.lifetime_add );
            GamePrint( "  Mana Cost: " .. total_used_mana );
            print( "Wand fired:");
            print( deck_fired_string );
            print( "  Projectile Damage: " .. thousands_separator(state.damage_projectile_add * 25) );
            print( "  Projectiles: " .. shot_projectile_count );
            print( "  Speed Multiplier: " .. state.speed_multiplier );
            print( "  Lifetime Add: " .. state.lifetime_add );
            print( "  Mana Cost: " .. total_used_mana );
            print( "  Called Actions: " .. #called_actions );
            print( "  Extra Entities: "..state.extra_entities );
            print( "  Game Effect Entities: "..state.game_effect_entities );
            local string = deck_fired_string.." resolves into:\n";
            for k,v in pairs( called_actions ) do
                local depth_string = "";
                for i=1,v.depth do
                    depth_string = depth_string .."\t";
                end
                string = string..depth_string..v.action.id;
                if v.dont_draw == true then
                    string = string.." (Can't Draw)";
                end
                string = string.."\n";
            end
            print( string );
        end
        GlobalsSetValue( "spell_lab_last_cast_frame", tostring( GameGetFrameNum() ) );
        called_actions = {};
    end
    _register_action( state );
    return state;
end

--[[
function spell_lab_draw_action( instant_reload_if_empty )
	local action = nil

	state_cards_drawn = state_cards_drawn + 1

	if reflecting then  return  end


	if ( #deck <= 0 ) then
		if instant_reload_if_empty and ( force_stop_draws == false ) then
			move_discarded_to_deck()
			order_deck()
			start_reload = true
		else
			reloading = true
			return true -- <------------------------------------------ RETURNS
		end
	end

	if #deck > 0 then
		-- draw from the start of the deck
		action = deck[ 1 ]

		table.remove( deck, 1 )
		
		-- update mana
		local action_mana_required = action.mana
		if action.mana == nil then
			action_mana_required = ACTION_MANA_DRAIN_DEFAULT
		end

		if action_mana_required > mana then
			OnNotEnoughManaForAction()
			table.insert( discarded, action )
			return false -- <------------------------------------------ RETURNS
		end

		if action.uses_remaining == 0 then
			table.insert( discarded, action )
			return false -- <------------------------------------------ RETURNS
		end

        total_used_mana = total_used_mana + action_mana_required;
		mana = mana - action_mana_required
	end

	--- add the action to hand and execute it ---
	if action ~= nil then
		play_action( action )
	end

	return true
end]]

function action_called( action )
    --table.insert( called_actions, { action = action, depth = current_draw_depth or 0, dont_draw = dont_draw_actions } );
end

local _draw_action = draw_action;
function draw_action( instant_reload_if_empty )
    --current_draw_depth = ( current_draw_depth or 0 ) + 1;
    if not reflecting then
		if #deck <= 0 then
			if instant_reload_if_empty and ( force_stop_draws == false ) then
				if #discarded > 0 then
					GlobalsSetValue("spell_lab_last_spell_wrap_frame", tostring( GameGetFrameNum() ) );
					GlobalsSetValue("spell_lab_last_spell_wrap_amount", tostring( #discarded ) );
				end
			end
		end
	end
	local result = _draw_action( instant_reload_if_empty );
    return result;
end

local _add_projectile = add_projectile;
function add_projectile( filepath )
    if not reflecting then
        shot_projectile_count = shot_projectile_count + 1;
        if ModSettingGet( "spell_lab.disable_projectiles" ) ~= true then
            _add_projectile( filepath );
        end
    else
        _add_projectile( filepath );
    end
end