--- Starts a hacking minigame based on the specified type and arguments.
-- This function dynamically calls the appropriate minigame function based on the provided type.
-- The function name should match the minigame's corresponding export name.
---@param type string The type of hacking minigame to start (e.g., 'ps-circle', 'ps-maze', 'mhacking-start', etc.)
---@param callback function The callback function to handle success or failure (optional).
---@param ... any Additional arguments to pass to the minigame function.
SD.StartHack = function(type, callback, ...)
    local minigameFunctions = {
        ['ps-circle']               = function(cb, ...) exports['ps-ui']:Circle(cb, ...) end,
        ['ps-maze']                 = function(cb, ...) exports['ps-ui']:Maze(cb, ...) end,
        ['ps-varhack']              = function(cb, ...) exports['ps-ui']:VarHack(cb, ...) end,
        ['ps-thermite']             = function(cb, ...) exports['ps-ui']:Thermite(cb, ...) end,
        ['ps-scrambler']            = function(cb, ...) exports['ps-ui']:Scrambler(cb, ...) end,
        ['memorygame-thermite']     = function(cb, correctBlocks, incorrectBlocks, timetoShow, timetoLose) exports['memorygame']:thermiteminigame(correctBlocks, incorrectBlocks, timetoShow, timetoLose, function() cb(true) end, function() cb(false) end) end,
        ['ran-memorycard']          = function(cb, ...) cb(exports['ran-minigames']:MemoryCard(...)) end,
        ['ran-openterminal']        = function(cb, ...) cb(exports['ran-minigames']:OpenTerminal(...)) end,
        ['hacking-opengame']        = function(cb, puzzleDuration, puzzleLength, puzzleAmount) exports['hacking']:OpenHackingGame(puzzleDuration, puzzleLength, puzzleAmount, function(success) cb(success) end) end,
        ['howdy-begin']             = function(cb, ...) cb(exports['howdy-hackminigame']:Begin(...)) end,
        ['sn-memorygame']           = function(cb, ...) cb(exports['SN-Hacking']:MemoryGame(...)) end,
        ['sn-skillcheck']           = function(cb, ...) cb(exports['SN-Hacking']:SkillCheck(...)) end,
        ['sn-thermite']             = function(cb, ...) cb(exports['SN-Hacking']:Thermite(...)) end,
        ['sn-keypad']               = function(cb, ...) cb(exports['SN-Hacking']:KeyPad(...)) end,
        ['sn-colorpicker']          = function(cb, ...) cb(exports['SN-Hacking']:ColorPicker(...)) end,
        ['rm-typinggame']           = function(cb, ...) cb(exports['rm_minigames']:typingGame(...)) end,
        ['rm-timedlockpick']        = function(cb, ...) cb(exports['rm_minigames']:timedLockpick(...)) end,
        ['rm-timedaction']          = function(cb, ...) cb(exports['rm_minigames']:timedAction(...)) end,
        ['rm-quicktimeevent']       = function(cb, ...) cb(exports['rm_minigames']:quickTimeEvent(...)) end,
        ['rm-combinationlock']      = function(cb, ...) cb(exports['rm_minigames']:combinationLock(...)) end,
        ['rm-buttonmashing']        = function(cb, ...) cb(exports['rm_minigames']:buttonMashing(...)) end,
        ['rm-angledlockpick']       = function(cb, ...) cb(exports['rm_minigames']:angledLockpick(...)) end,
        ['rm-fingerprint']          = function(cb, ...) cb(exports['rm_minigames']:fingerPrint(...)) end,
        ['rm-circleclick']          = function(cb, ...) cb(exports['rm_minigames']:circleClick(...)) end,
        ['rm-hotwirehack']          = function(cb, ...) cb(exports['rm_minigames']:hotwireHack(...)) end,
        ['rm-hackerminigame']       = function(cb, ...) cb(exports['rm_minigames']:hackerMinigame(...)) end,
        ['rm-safecrack']            = function(cb, ...) cb(exports['rm_minigames']:safeCrack(...)) end,
        ['bl-circlesum']            = function(cb, iterations, config) cb(exports['bl_ui']:CircleSum(iterations or 1, config)) end,
        ['bl-digitdazzle']          = function(cb, iterations, config) cb(exports['bl_ui']:DigitDazzle(iterations or 1, config)) end,
        ['bl-lightsout']            = function(cb, iterations, config) cb(exports['bl_ui']:LightsOut(iterations or 1, config)) end,
        ['bl-minesweeper']          = function(cb, iterations, config) cb(exports['bl_ui']:MineSweeper(iterations or 1, config)) end,
        ['bl-pathfind']             = function(cb, iterations, config) cb(exports['bl_ui']:PathFind(iterations or 1, config)) end,
        ['bl-printlock']            = function(cb, iterations, config) cb(exports['bl_ui']:PrintLock(iterations or 1, config)) end,
        ['bl-untangle']             = function(cb, iterations, config) cb(exports['bl_ui']:Untangle(iterations or 1, config)) end,
        ['bl-wavematch']            = function(cb, iterations, config) cb(exports['bl_ui']:WaveMatch(iterations or 1, config)) end,
        ['bl-wordwiz']              = function(cb, iterations, config) cb(exports['bl_ui']:WordWiz(iterations or 1, config)) end,
        ['glitch-firewall-pulse']   = function(cb, ...) cb(exports['glitch-minigames']:StartFirewallPulse(...)) end,
        ['glitch-backdoor-sequence']= function(cb, ...) cb(exports['glitch-minigames']:StartBackdoorSequence(...)) end,
        ['glitch-circuit-rhythm']   = function(cb, ...) cb(exports['glitch-minigames']:StartCircuitRhythm(...)) end,
        ['glitch-surge-override']   = function(cb, ...) cb(exports['glitch-minigames']:StartSurgeOverride(...)) end,
        ['glitch-circuit-breaker']  = function(cb, ...) cb(exports['glitch-minigames']:StartCircuitBreaker(...)) end,
        ['glitch-data-crack']       = function(cb, ...) cb(exports['glitch-minigames']:StartDataCrack(...)) end,
        ['glitch-brute-force']      = function(cb, ...) cb(exports['glitch-minigames']:StartBruteForce(...)) end,
    }

    if minigameFunctions[type] then
        minigameFunctions[type](callback, ...)
    else
        error(string.format("Unknown hacking minigame type: %s", type))
    end
end

return SD
