SD.Name = {}

SD.Name.GetFullName = function()
    local fullName = SD.Callback.Await('sd_lib:getFullName')
    return(fullName)
end

SD.Name.GetFirstName = function()
    local firstName = SD.Callback.Await('sd_lib:getFirstName')
    return(firstName)
end

SD.Name.GetLastName = function()
    local lastName = SD.Callback.Await('sd_lib:getLastName')
    return(lastName)
end

return SD.Name







