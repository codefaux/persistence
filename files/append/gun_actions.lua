function action_called( action ) end
called_actions = {};
for k,v in pairs( actions ) do
    local original_function = v.action;
    v.action = function(...)
        if not reflecting then
            action_called( v );
        end
        current_draw_depth = ( current_draw_depth or 0 ) + 1;
        local result = original_function(...);
        current_draw_depth = current_draw_depth - 1;
        return result;
    end
end