local state = {
    currentState = nil,
}

function state.switch(nextState, ...)
    -- initialize previous state (or the default nil)
    local previous = state.currentState

    -- set the current state to the state it is switching to
    state.currentState = nextState

    -- confirms currentState exists and it has an enter function, then calls it with the previous state and any additional arguments
    if state.currentState and state.currentState.enter then
        state.currentState:enter(previous, ...)
    end
end

function state.current()
    return state.currentState
end

return state