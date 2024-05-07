-- Assign the detected 'Framework' to 'SD.Framework' to enable global identification
-- of the current framework. This allows scripts to implement framework-specific logic
-- by checking 'SD.Framework', differentiating between frameworks like ESX and QB.
SD.Framework = Framework

return SD.Framework