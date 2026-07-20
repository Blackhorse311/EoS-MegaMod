--#define DEEP_LOGGING

-- #ifdef DEEP_LOGGING
--     inspect = require("Libs.inspect")
-- #endif

local StringHandle = require("Libs.StringHandle")
local Clone = require("Libs.Clone")
local PrintUtils = require("Libs.PrintR")

local _tablePool = newTablePool({initialCapacity = 4, incrementalCapacity = 2})

local config = {}
config.idLookupTable = {} -- Map of string ids ==> definitions
local definitions = {} -- The original definitions before compilation
local extensions = {} -- The original extensions before compilation
local compiledDefinitions = { empty = true }  -- The compiled definitions and extensions
config.defs = compiledDefinitions
declareGlobal("Config", config.defs)
local configTags = {}
local allowOverrides = false -- When true, will not log an error when an existing Namespace/ID is overridden

local scriptLoadNamespaces = {}

local _curDef
local defImpl = function(def)
    _curDef = def
end

local _curPersist
local persistImpl = function(persist)
    _curPersist = persist
end

local _curLimits
local limitImpl = function(limits)
    _curLimits = limits
end

local _curLoadFilePath

local function loadWarn(s)
    logError(string.format("Error loading: %s - %s", tostring(_curLoadFilePath), s))
end

local function configBuildingLink(configId, overridesOrFunction)
    local key
    if type(configId) == "table" then
        key = configId[2]
        configId = configId[1]
    end
    local link = { __rgLink = configId, k = key }
    if type(overridesOrFunction) == "function" then
        link.f = overridesOrFunction
    else
        link.o = overridesOrFunction
    end
    return link
end

local function linkValue(configId, valueKey)
    return configBuildingLink(configId, function(entry) return entry[valueKey] end)
end

local scriptLoadEnvDefs =
{
    def = defImpl,
    persist = persistImpl,
    limit_var = limitImpl,
    link = configBuildingLink,
    linkValue = linkValue,
    client = client,
    type = type,
    math = math,
    string = string,
    table = table,
    print = print,
    printI = PrintUtils.printI,
    printR = PrintUtils.printR,
    tostring = tostring,
    TableUtils = require("Libs.TableUtils"),
    logWarning = logWarning,
    logError = logError,
    throwException = throwException,
    assert = assert,
    Vector2 = UnityEngine.Vector2,
    Vector3 = UnityEngine.Vector3,
    Navigable = RomeroGames.Navigable,
    ProxyIconMode = RomeroGames.ProxyIconMode,
    logGameInfo = logGameInfo,
    clearTable = clearTable,
    DLCName = RomeroGames.DLCName,
}

local scriptFunctionNewIndex = function(o, k, v)
    if type(v) == "function" then
        -- Make _defs if required
        if _curDef then
            local defs = o._defs
            if not defs then
                defs = {}
                rawset(o, "_defs", defs)
            end
            -- Store meta information
            defs[k] = _curDef
            _curDef = nil
        end
        rawset(o, k, v)
    end

    if _curPersist then
        logError(string.format("Unable to apply persistence to %s. Persistent variables are only allowed in the top level of scripts.", k))
        _curPersist = nil
    end

    if _curLimits then
        logError(string.format("Unable to apply limits to %s. Limited variables are only allowed in the top level of scripts.", k))
        _curLimits = nil
    end
end

local scriptFunctionMT =
{
    __newindex = scriptFunctionNewIndex,
}

local scriptLocalIndex = function(o, k)
    local v = scriptLoadEnvDefs[k]
    if v ~= nil then return v end

    local namespace = scriptLoadNamespaces[#scriptLoadNamespaces]
    if namespace == nil then
        if k == "client" then
            return client
        elseif k == "DLCName" then
            return RomeroGames.DLCName
        end
        loadWarn("Unable to get entry (" .. tostring(k) .. "). _namespace was not defined.")
        return
    end

    local name = namespace[#namespace]
    if name == nil then
        if k == "client" then
            return client
        elseif k == "DLCName" then
            return RomeroGames.DLCName
        else
            loadWarn("Unable to get entry (" .. tostring(k) .. "). _id was not defined.")
            return
        end
    end

    return name[k]
end

local scriptLocalNewIndex = function(o, k, v)
    if scriptLoadEnvDefs[k] then
        loadWarn("Unable to set reserved script variable: " .. k)
        return
    end

    if k == "_namespace" then
        scriptLoadNamespaces[#scriptLoadNamespaces + 1] = {_namespace = v}
    elseif k == "_id" or k == "_extends" then
        local namespace = scriptLoadNamespaces[#scriptLoadNamespaces]
        if namespace == nil then
            loadWarn("Unable to process new _id (" .. tostring(k) .. "). _namespace was not defined.")
        else
            -- NB: If updating this table, be sure to update the rgLuaCheck static analysis script
            local newEntry = {
                [k] = v,
                _nilVars = {},
                _defs = {},
                _tags = {},
                GameEvent = setmetatable({}, scriptFunctionMT),
                ObjectEvent = setmetatable({}, scriptFunctionMT),
                TimeSlice = setmetatable({}, scriptFunctionMT),
                Modifier = setmetatable({}, scriptFunctionMT),
                Command = setmetatable({}, scriptFunctionMT),
            }
            -- TODO: This should be replaced with its own system
            newEntry.Message = newEntry.Modifier
            namespace[#namespace + 1] = newEntry
        end
    elseif k == "_tags" then
        local namespace = scriptLoadNamespaces[#scriptLoadNamespaces]
        if namespace == nil then
            loadWarn(string.format("Unable to process new entry (%s). _namespace was not defined.", tostring(k)))
            return
        end

        -- Get the latest namespace definition
        local entry = namespace[#namespace]
        if entry == nil then
            loadWarn(string.format("Unable to process new entry (%s). _id was not defined.", tostring(k)))
            return
        end

        local tags = entry._tags
        local typeV = type(v)
        if typeV == "table" then
            for idx, tag in next, v do
                local typeIdx = type(idx)
                if typeIdx == "number" then
                    -- Tags defined in the form {"Tag", "OtherTag", ...}
                    tags[tag] = true
                elseif typeIdx == "string" and type(tag) == "boolean" then
                    -- Tags defined in the form {Tag = true, OtherTag = false}
                    tags[idx] = tag
                end
            end
        elseif typeV == "string" then
            tags[v] = true
        end
    else
        local namespace = scriptLoadNamespaces[#scriptLoadNamespaces]
        if namespace == nil then
            loadWarn(string.format("Unable to process new entry (%s). _namespace was not defined.", tostring(k)))
            return
        end

        local entry = namespace[#namespace]
        if entry == nil then
            loadWarn(string.format("Unable to process new entry (%s). _id was not defined.", tostring(k)))
            return
        end

        if _curDef then
            entry._defs[k] = _curDef
            _curDef = nil
        end

        if _curPersist then
            if type(v) == "function" then
                loadWarn(string.format("Warning while assigning persistent variable %s in %s.%s. Function references can not be saved, are you sure this variable should be persistent?", k, namespace._namespace, entry._id))
            end
            local curDefs = entry._defs[k]
            if not curDefs then
                curDefs = {}
                entry._defs[k] = curDefs
            end

            curDefs.persist = _curPersist
            _curPersist = nil
        end

        if _curLimits then
            if type(v) ~= "number" then
                loadWarn(string.format("Warning while assigning limited variable %s in %s.%s. Are you sure this variable should be limited (must be a number)?", k, namespace._namespace, entry._id))
            end
            local curDefs = entry._defs[k]
            if not curDefs then
                curDefs = {}
                entry._defs[k] = curDefs
            end

            curDefs.limits = _curLimits
            _curLimits = nil
        end

        if v == nil then
            entry._nilVars[k] = true
        else
            entry[k] = v
        end
    end
end

local scriptLoadEnv = setmetatable({},
    {
        __index = scriptLocalIndex,
        __newindex = scriptLocalNewIndex,
    }
)

local function clearCompiledDefinitions(namespace)
    compiledDefinitions[namespace] = {}
end

local function getOrCreateCompiledDefinitions(namespace)
    if compiledDefinitions[namespace] == nil then
        clearCompiledDefinitions(namespace)
    end
    return compiledDefinitions[namespace]
end

local function updateKeys_R(existing, overrides)
    -- #ifdef DEEP_LOGGING
    --     print(string.format("updateKeys_R"))
    -- #endif

    for k,v in next, overrides do

        -- #ifdef DEEP_LOGGING
        --     print(" override: " .. k)
        -- #endif

        local existingVal = existing[k]
        local vIsTable = type(v) == "table"
        if type(existingVal) == "table" and vIsTable then
            updateKeys_R(existingVal, v)
        else
            -- Replace existing value
            if vIsTable then
                existing[k] = Clone.deep(v)
            else
                existing[k] = v
            end
        end
    end
end

local function includeConfig_Recursive(child, parent)
    for k, v in next, parent do
        local childVal = child[k]
        if (type(childVal) == "table") and (type(v) == "table") then
            childVal = Clone.shallow(childVal)
            includeConfig_Recursive(childVal, v)
            child[k] = childVal
        else
            if childVal == nil then
                child[k] = v
            end
        end
    end
end

local function includeConfig(child, parent)
    for k,v in next, parent do
        local childVal = child[k]
        if childVal ~= v then
            if childVal == nil then
                child[k] = v
            else
                if type(v) =="table" then
                    if type(childVal) == "table" then
                        childVal = Clone.shallow(childVal)
                        includeConfig_Recursive(childVal, v)
                        child[k] = childVal
                    end
                end
            end
        end
    end
end

local function updateLinks_R(entry, parentLinks)

    if rawget(entry,"__rgLink") then
        local configId = entry.__rgLink
        local overrides = entry.o
        local customFunction = entry.f
        local key = entry.k
        if parentLinks[configId] then
            logError("Circular link detected: ".. tostring(configId))
        else
            parentLinks[configId .. "." .. (key or "")] = true
            local linkConfig = config.idLookupTable[configId]
            if not linkConfig then
                logError("Unknown link config: " .. tostring(configId))
            else
                if key then
                    linkConfig = linkConfig[key]
                    if linkConfig == nil then
                        logError("Unknown link config key: " .. tostring(configId) .. ", " .. tostring(key))
                    end
                end
                if type(linkConfig) == "table" then
                    local isVal, val = updateLinks_R(linkConfig, parentLinks)
                    if isVal then
                        logError("Unknown config link error!")
                    else
                        if overrides then
                            linkConfig = Clone.deep(linkConfig)
                            updateLinks_R(overrides, parentLinks)
                            updateKeys_R(linkConfig, overrides)
                        elseif customFunction then
                            linkConfig = customFunction(linkConfig)
                            return true, linkConfig
                        end
                    end
                    clearTable(entry)
                    for k,v in pairs(linkConfig) do
                        entry[k] = v
                    end
                else
                    return true, linkConfig
                end
            end
            parentLinks[configId] = nil
        end
    else
        for k,v in pairs(entry) do
            if type(v) == "table" then
                local isVal, val = updateLinks_R(v, parentLinks)
                if isVal then entry[k] = val end
            end
        end
    end

    -- Stripping unwanted keys
    entry._includes = nil

end

local function compileEntry(entryNamespace, entryName, recursiveOverflowGuard)

    -- #ifdef DEEP_LOGGING
        -- print(string.format("compileEntry:begin:%s:%s:%s", entryNamespace, entryName, inspect(recursiveOverflowGuard)))
    -- #endif

    -- If this entry has already been compiled then it can be skipped.
    if compiledDefinitions[entryNamespace] and compiledDefinitions[entryNamespace][entryName] then
        return
    end

    -- Read the entry data
    if definitions[entryNamespace] == nil then
        logError("Could not compile config: " .. tostring(entryName) .. " - namespace does not exist: " .. tostring(entryNamespace))
        return
    end
    local entryData = definitions[entryNamespace][entryName]
    if entryData == nil then
        logError("Could not compile config: " .. tostring(entryNamespace) .. "." .. tostring(entryName) .. " - entry does not exist")
        return
    end

    local fullConfigId = entryNamespace .. "." .. entryName

    local isAbstract = entryData._abstract

    -- Merge in any extensions
    local entryExtensionsNamespace = extensions[entryNamespace]
    if entryExtensionsNamespace then
        local entryExtensions = entryExtensionsNamespace[entryName]
        if entryExtensions then
            -- print("Found entry extensions for", fullConfigId)
            for i = 1, #entryExtensions do
                -- print("  Merging extension", i)
                local entryExtension = entryExtensions[i]
                updateKeys_R(entryData, entryExtension)
            end
        end
    end

    entryData._abstract = nil

    -- print(string.format("about to compile:%s:%s", entryNamespace, entryName))

    -- #ifdef DEEP_LOGGING
    --     printI(entryData)
    -- #endif

    -- Compile parent namespace if present

    local compiledParents = {}
    if type(entryData._includes) == "string" then entryData._includes = { entryData._includes } end
    if entryData._includes then
        for _,parent in ipairs(entryData._includes) do
            local parentNamespace = entryNamespace
            local parentEntryName = parent

            -- Get optional parent namespace and parent entry name
            local startPos = parent:match('^.*()%.')
            if startPos ~= nil then
                parentEntryName = string.sub(parent, startPos + 1)
                parentNamespace = string.sub(parent, 1, startPos - 1)
            end

            -- Compile parent if not already compiled
            local compiledParent = compiledDefinitions[parentNamespace] and compiledDefinitions[parentNamespace][parentEntryName]
            if not compiledParent then

                -- Check for parent inheritence loops
                local guardNamespace = recursiveOverflowGuard[parentNamespace]
                if guardNamespace and guardNamespace[parentEntryName] then
                    printR(entryData._includes)
                    throwException("compileEntry failed: parent inheritance loop detected: " .. entryNamespace .. "." .. entryName .. " with parent: ".. parentNamespace .. "." .. parentEntryName)
                    return nil
                end

                -- Add a new recursive guard
                if guardNamespace == nil then
                    guardNamespace = {}
                    recursiveOverflowGuard[parentNamespace] = guardNamespace
                end
                guardNamespace[parentEntryName] = true
                compiledParent = compileEntry(parentNamespace, parentEntryName, recursiveOverflowGuard)
            end
            compiledParents[#compiledParents+1] = compiledParent
        end
    end


    local newEntry
    -- Merge with parent (if it exists)
    if #compiledParents > 0 then
        newEntry = {}
        for k, v in next, entryData do
            newEntry[k] = entryData[k]
        end
        for i = #compiledParents, 1, -1 do
            local parent = compiledParents[i]
            includeConfig(newEntry, parent)
        end
    else
        -- Just copy raw config
        -- #ifdef DEEP_LOGGING
        --     print("Copying raw config from entryData")
        --     printI(entryData)
        -- #endif
        newEntry = Clone.deep(entryData)
        -- #ifdef DEEP_LOGGING
        --     print("After cloning entryData")
        --     printI(newEntry)
        -- #endif
    end
    newEntry._includes = nil
    newEntry.__rgIsCompiledAbstract = nil

    -- Ensure slot exists for compiled config
    local compiledNamespace = getOrCreateCompiledDefinitions(entryNamespace)
    compiledNamespace[entryName] = newEntry

    -- Set the global definition for this entry
    if isAbstract then
        newEntry.__rgIsCompiledAbstract = true
    else
        config.idLookupTable[fullConfigId] = newEntry
    end
    return newEntry
end

function config.addCompiledEntry(namespace, entryId, entryConfig)
    local fullConfigId = namespace .. "." .. entryId
    if not config.idLookupTable[fullConfigId] then
        config.defs[namespace][entryId] = entryConfig
        config.idLookupTable[fullConfigId] = entryConfig
    end
end

function config.fromId(id)
    return config.idLookupTable[id]
end

function config.hasTag(id, tag)
    local entry = config.idLookupTable[id]
    local tags = entry and entry._tags
    return not not (tags and tags[tag])
end

function config.define(namespace, newDefinitions)

    -- #ifdef DEEP_LOGGING
    --     print(string.format("config.define:%s", namespace))
    -- #endif

    assert(namespace, "Unable to define config: namespace must be provided")
    assert(newDefinitions, "Unable to define config: definitions must be provided")

    -- Override existing definitions
    local defs = definitions[namespace] or {}
    for k,v in next, newDefinitions do
        if defs[k] and not allowOverrides then
            logError("Config definition already exists:", namespace, tostring(k))
        end
        defs[k] = v
    end
    definitions[namespace] = defs
end

function config.extend(namespace, newDefinitions)
    assert(namespace, "Unable to extend config: namespace must be provided")
    assert(newDefinitions, "Unable to extend config: definitions must be provided")

    local defs = extensions[namespace] or {}
    for k,v in next, newDefinitions do
        local defExtensions = defs[k] or {}
        defExtensions[#defExtensions + 1] = v
        defs[k] = defExtensions
    end
    extensions[namespace] = defs
end

function config.clearDefinitions()
    definitions = {}
    extensions = {}
    compiledDefinitions = {}
    config.defs = compiledDefinitions
    _G.Config = config.defs
end

local _variantKeyMaps =
{
    "_VARIANT_1",
    "_VARIANT_2",
    "_VARIANT_3",
    "_VARIANT_4",
    "_VARIANT_5",
    "_VARIANT_6",
    "_VARIANT_7",
    "_VARIANT_8",
    "_VARIANT_9",
    "_VARIANT_10",
    "_VARIANT_11",
    "_VARIANT_12",
}

local function _walkVariants(namespace, entryName, variantSuffix, variantDefinition, variantDataSection, originalDataSection)
    for k, v in next, variantDefinition do
        if type(v) == "table" then
            local variantChild = variantDataSection[k]
            if variantChild == nil then
                variantChild = {}
                variantDataSection[k] = variantChild
            elseif type(variantChild) ~= "table" then
                logError("Unexpected error parsing config variant:", namespace, entryName)
                break
            end
            _walkVariants(namespace, entryName, variantSuffix, v, variantChild, originalDataSection[k])
        elseif v then
            local originalVal = originalDataSection[k]
            if type(originalVal) == "string" then
                variantDataSection[k] = originalVal .. variantSuffix
                -- print("Setting variant value", k, variantDataSection[k])
            end
        end
    end
end

local _newVariantsForNamespace = {}
function config.compileAll()
    -- #ifdef DEEP_LOGGING
    --     print("compileAll")
    -- #endif

    local next = next

    -- Proecess Variants

    local defaultFieldsDef =
    {
        _includes =
        {
            [1] = true
        }
    }

    local totalNumVariants = 0
    local table_insert = table.insert
    for namespace, definitionsForNamespace in next, definitions do
        clearTable(_newVariantsForNamespace)
        for entryName, entryData in next, definitionsForNamespace do
            local variantsDef = entryData._variants
            if variantsDef then
                entryData._variants = nil -- Remove this from the entry data to avoid creating more
                local numVariants = variantsDef.numVariants or 0
                -- print("Found variant definition", namespace, entryName, numVariants)
                local fieldsDef = variantsDef.fields or defaultFieldsDef
                for i = 1, numVariants do
                    local variantSuffix = _variantKeyMaps[i] or ("_VARIANT_" .. i)
                    local newEntry = Clone.deep(entryData)
                    _walkVariants(namespace, entryName, variantSuffix, fieldsDef, newEntry, entryData)
                    local newEntryName = entryName .. variantSuffix
                    _newVariantsForNamespace[newEntryName] = newEntry
                end
            end
        end
        for variantName, variantData in next, _newVariantsForNamespace do
            -- printR(variantData, 3, "Adding variant ".. namespace .. "." .. variantName)
            definitionsForNamespace[variantName] = variantData
            totalNumVariants = totalNumVariants + 1
        end
    end

    -- print("Total Desired Num Variants", totalNumVariants)

    for n,c in next, definitions do
        config.compile(n)
    end


    -- Remove tables that are no longer used
    definitions = {}

    -- collectgarbage()
    -- collectgarbage()
    -- print("Memory before links", collectgarbage("count"))

    for n,nv in next, compiledDefinitions do
        for c, cv in next, nv do
            -- Remove abstract compiled classes
            if cv.__rgIsCompiledAbstract then
                -- printR(cv, 1, "Removing abstract compiled class:" .. n .. "." .. c)
                nv[c] = nil
            else
                -- Strip out unwanted fields and clear metatables
                cv._includes = nil
                if cv.GameEvent then
                    if next(cv.GameEvent) == nil then
                        cv.GameEvent = nil
                    else
                        setmetatable(cv.GameEvent, nil)
                    end
                end

                if cv.ObjectEvent then
                    if next(cv.ObjectEvent) == nil then
                        cv.ObjectEvent = nil
                    else
                        setmetatable(cv.ObjectEvent, nil)
                    end
                end

                if cv.TimeSlice then
                    if next(cv.TimeSlice) == nil then
                        cv.TimeSlice = nil
                    else
                        setmetatable(cv.TimeSlice, nil)
                    end
                end

                if cv.Modifier then
                    if next(cv.Modifier) == nil then
                        cv.Modifier = nil
                    else
                        setmetatable(cv.Modifier, nil)
                    end
                end
                cv.Message = cv.Modifier -- Todo: see comment above about making cv.Message it's own system

                if cv.Command then
                    if next(cv.Command) == nil then
                        cv.Command = nil
                    else
                        setmetatable(cv.Command, nil)
                    end
                end

                if cv._defs and next(cv._defs) == nil then
                    cv._defs = nil
                end

                if cv._nilVars and next(cv._nilVars) == nil then
                    cv._nilVars = nil
                end

                local isVal, val = updateLinks_R(cv, {})
                if isVal then
                    cv[c] = val
                end
            end
        end
    end
end

function config.compile(namespace)
    -- #ifdef DEEP_LOGGING
    --     print("config.compile " .. namespace)
    -- #endif
    assert(namespace and type(namespace) == "string", "Unable to compile config: namespace string must be provided")

    clearCompiledDefinitions(namespace)

    local definitionsForNamespace = definitions[namespace]
    if definitionsForNamespace == nil then
        -- #ifdef DEEP_LOGGING
        --     print("config.compile " .. namespace .. " is empty")
        -- #endif
        return
    end

    for entryName, entryData in next, definitionsForNamespace do
        if not entryData._abstract then
            compileEntry(namespace, entryName, {})
        end
    end
end

local function processScriptBlocks(ctx)
    for i = 1, #ctx do
        local namespace = ctx[i]
        for j = 1, #namespace do
            local cur = namespace[j]
            local id = cur._id
            local extends = cur._extends
            cur._id = nil
            cur._extends = nil
            local scriptBlockProcessTable = { [id or extends] = Clone.shallow(cur) }
            if id ~= nil then
                config.define(namespace._namespace, scriptBlockProcessTable)
            else
                config.extend(namespace._namespace, scriptBlockProcessTable)
            end
        end
    end
end

function config.loadConfigs()
    if rgperf then rgperf.pushMarker("loadConfigs") end
    local configList = client.config:getAllConfigFiles()
    local scriptList = client.config:getAllScriptFiles()

    config.loadConfigsFromFiles(configList, scriptList)
    if rgperf then rgperf.popMarker() end
end

function config.loadConfigsFromFiles(configList, scriptList)
    -- #ifdef DEEP_LOGGING
    --     print("config.loadConfigs")
    -- #endif

    config.clearDefinitions()
    declareGlobal("link", configBuildingLink)

    --collectgarbage()
    --collectgarbage()
    --logInfo("Mem size before config load", collectgarbage("count"))

    if rgperf then rgperf.pushMarker("loadConfigs doFile") end
    for i = 1, #configList do
        dofile(configList[i])
    end
    if rgperf then rgperf.popMarker() end

    _G.link = nil

    local setfenv = setfenv
    for i = 1, #scriptList do
        local path = scriptList[i]
        if rgperf then rgperf.pushMarker("loadConfigs loadFile") end
        local scriptFunc = loadfile(path)
        if rgperf then rgperf.popMarker() end
        if not scriptFunc then
            logError("Unable to load file: " .. path)
        else
            if rgperf then rgperf.pushMarker("loadConfigs processScripts") end
            _curLoadFilePath = path
            clearTable(scriptLoadNamespaces)
            setfenv(scriptFunc, scriptLoadEnv)
            -- print("ScriptyLoad: ", path)
            scriptFunc()
            -- printR(scriptLoadNamespaces)
            processScriptBlocks(scriptLoadNamespaces)
            if rgperf then rgperf.popMarker() end
        end
    end

    if rgperf then rgperf.pushMarker("loadConfigs compile") end
    config.compileAll()

    -- Gather up all the script tags
    clearTable(configTags)
    for nsId, namespace in next, compiledDefinitions do
        for id, data in next, namespace do
            if data._tags and type(data._tags) == "table" then
                for tag, v in next, data._tags do
                    if v then
                        local tagDef = configTags[tag]
                        if tagDef == nil then
                            tagDef = {}
                            configTags[tag] = tagDef
                        end
                        tagDef[#tagDef+1] = nsId .. "." .. id
                    end
                end
            end
        end
    end
    definitions = nil
    extensions = nil
    if rgperf then rgperf.popMarker() end
    collectgarbage()
    collectgarbage()
    -- logInfo("Mem size after config load", collectgarbage("count"))
end

local function configTagIterator(data)
    local i = data.idx
    local id = data.tagData[i]
    if id then
        data.idx = i + 1
        return id
    end
    _tablePool:releaseAndClear(data)
    return nil
end

local function emptyIterator() end

function config.getIdsFromTag(tag)
    local tagData = configTags[tag]
    if tagData then
        local data = _tablePool:acquire()
        data.tagData = data
        data.idx = 1
        return configTagIterator, data
    else
        return emptyIterator
    end
end

local function findConfigsCoro(namespacePattern, configPattern)
    -- #ifdef DEEP_LOGGING
    --     print ("config.findConfigsCoro " .. tostring(namespacePattern) .. "  " .. tostring(configPattern))
    -- #endif
    for n,c in pairs(config.defs) do
        if namespacePattern == nil or string.match(n, namespacePattern) then
            if configPattern then
                for k,v in pairs(c) do
                    if string.match(k, configPattern) then
                        -- print("Found: " .. n .. "." .. k)
                        coroutine.yield(n, k, v)
                    end
                end
            else
                for k,v in pairs(c) do
                    -- print("Found: " .. n .. "." .. k)
                    coroutine.yield(n, k, v)
                end
            end
        end
    end
end

local function findNamespacesCoro(namespacePattern)
    for n,c in pairs(config.defs) do
        if namespacePattern == nil or string.match(n, namespacePattern) then
            coroutine.yield(n, c)
        end
    end
end

local function findChildNamespacesCoro(namespace)
    if namespace == nil then
        return nil
    end
    -- Namespaces use the '.' character to split
    local pattern = "^" .. namespace .. '%.'
    for n,c in pairs(config.defs) do
        if string.match(n, pattern) then
            coroutine.yield(n, c)
        end
    end
end

--- Iterator for finding matching configs in namespaces using lua pattern matching.
-- Example: Find all configs whose name contains "BREWERY" in namespaces whose name begins with "BUILDING."
--          for namespace, configName, configValue in config.findConfigs("^BUILDINGS%.", "BREWERY") do
--              -- Do things with the matching namespace, configName and configValue
--          end
-- @param namespacePattern Lua pattern to use to find matching namespaces - can be nil to match against all namespaces
-- @param configValue Lua pattern to use to find matching configuration names for the matching namespaces - can be nil to match against all configuration names
-- @return matching namespace, configName, configValue
function config.findConfigs(namespacePattern, configPattern)
    return coroutine.wrap(function () findConfigsCoro(namespacePattern, configPattern) end)
end

--- Iterator for finding matching namespaces using lua pattern matching.
-- Example: for namespace, configs in config.findNamespaces("^BUILDINGS%.") do
--              -- Do things with the matching namespace and configs
--          end
-- @param namespacePattern Lua pattern to use to find matching namespaces
-- @return matching namespace, configsInNamespace
function config.findNamespaces(namespacePattern)
    return coroutine.wrap(function() findNamespacesCoro(namespacePattern) end )
end

--- Iterator for finding child namespaces
-- Example: for namespace, configs in config.findChildNamespaces("BUILDINGS") do
--              -- Do things with the matching namespace and configs
--          end
-- @param namespace The parent namespace name
-- @return child namespaces, configsInNamespace
function config.findChildNamespaces(namespace)
    return coroutine.wrap(function () findChildNamespacesCoro(namespace) end)
end

-- Dev-only utility functions
if Dev then
    function config.getConfigIds(namespacePattern, includeAbstract)
        local configs = {}
        -- for namespace, configs in config.findConfigs(namespacePattern, configPattern) do
        for namespace, configName, configValue in config.findConfigs(namespacePattern) do
            if includeAbstract or (not includeAbstract and (not configValue._abstract)) then
                configs[#configs+1] = namespace.."."..configName
            end
        end
        return configs
    end

    function config.getNamespaces(namespacePattern)
        local namespaces = {}
        for namespace, configs in config.findNamespaces(namespacePattern) do
            namespaces[#namespaces+1] = namespace
        end
        return namespaces
    end

    function config.getChildNamespaces(namespace)
        local childNamespaces = {}
        for ns, configs in config.findChildNamespaces(namespace) do
            childNamespaces[#childNamespaces+1] = ns
        end
        return childNamespaces
    end

    function config.isValidConfigId(configId)
        return config.idLookupTable[configId] ~= nil
    end
end
return config
