--- Starts a hacking minigame based on the specified type and arguments.
-- This function dynamically calls the appropriate minigame function based on the provided type.
-- The function name should match the minigame's corresponding export name.
---@param type string The type of hacking minigame to start (e.g., 'ps-circle', 'ps-maze', 'mhacking-start', etc.)
---@param callback function The callback function to handle success or failure (optional).
---@param ... any Additional arguments to pass to the minigame function.
SD.StartHack = function(type, callback, ...)
    local minigameFunctions = {
        ['ps-circle'] = function(cb, ...) exports['ps-ui']:Circle(cb, ...) end,
        ['ps-maze'] = function(cb, ...) exports['ps-ui']:Maze(cb, ...) end,
        ['ps-varhack'] = function(cb, ...) exports['ps-ui']:VarHack(cb, ...) end,
        ['ps-thermite'] = function(cb, ...) exports['ps-ui']:Thermite(cb, ...) end,
        ['ps-scrambler'] = function(cb, ...) exports['ps-ui']:Scrambler(cb, ...) end,
        ['memorygame-thermite'] = function(cb, correctBlocks, incorrectBlocks, timetoShow, timetoLose) local successCallback = function() cb(true) end local failCallback = function() cb(false) end exports['memorygame']:thermiteminigame(correctBlocks, incorrectBlocks, timetoShow, timetoLose, successCallback, failCallback) end,
        ['ran-memorycard'] = function(cb, ...) cb(exports['ran-minigames']:MemoryCard(...)) end,
        ['ran-openterminal'] = function(cb, ...) cb(exports['ran-minigames']:OpenTerminal(...)) end,
        ['hacking-opengame'] = function(cb, puzzleDuration, puzzleLength, puzzleAmount) local successCallback = function(success) cb(success) end exports['hacking']:OpenHackingGame(puzzleDuration, puzzleLength, puzzleAmount, successCallback) end,
        ['howdy-begin'] = function(cb, ...) cb(exports['howdy-hackminigame']:Begin(...)) end,
        ['sn-memorygame'] = function(cb, ...) cb(exports['SN-Hacking']:MemoryGame(...)) end,
        ['sn-skillcheck'] = function(cb, ...) cb(exports['SN-Hacking']:SkillCheck(...)) end,
        ['sn-thermite'] = function(cb, ...) cb(exports['SN-Hacking']:Thermite(...)) end,
        ['sn-keypad'] = function(cb, ...) cb(exports['SN-Hacking']:KeyPad(...)) end,
        ['sn-colorpicker'] = function(cb, ...) cb(exports['SN-Hacking']:ColorPicker(...)) end,
        ['rm-typinggame'] = function(cb, ...) cb(exports['rm_minigames']:typingGame(...)) end,
        ['rm-timedlockpick'] = function(cb, ...) cb(exports['rm_minigames']:timedLockpick(...)) end,
        ['rm-timedaction'] = function(cb, ...) cb(exports['rm_minigames']:timedAction(...)) end,
        ['rm-quicktimeevent'] = function(cb, ...) cb(exports['rm_minigames']:quickTimeEvent(...)) end,
        ['rm-combinationlock'] = function(cb, ...) cb(exports['rm_minigames']:combinationLock(...)) end,
        ['rm-buttonmashing'] = function(cb, ...) cb(exports['rm_minigames']:buttonMashing(...)) end,
        ['rm-angledlockpick'] = function(cb, ...) cb(exports['rm_minigames']:angledLockpick(...)) end,
        ['rm-fingerprint'] = function(cb, ...) cb(exports['rm_minigames']:fingerPrint(...)) end,
        ['rm-hotwirehack'] = function(cb, ...) cb(exports['rm_minigames']:hotwireHack(...)) end,
        ['rm-hackerminigame'] = function(cb, ...) cb(exports['rm_minigames']:hackerMinigame(...)) end,
        ['rm-safecrack'] = function(cb, ...) cb(exports['rm_minigames']:safeCrack(...)) end,
    }

    if minigameFunctions[type] then
        minigameFunctions[type](callback, ...)
    else
        error(string.format("Unknown hacking minigame type: %s", type))
    end
end

return SD.StartHack
