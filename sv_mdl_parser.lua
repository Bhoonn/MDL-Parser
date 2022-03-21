if CLIENT then return end

-- WARNING: THIS ONLY WORKS FOR CONTENT FOLDERS THAT HAVE CONTENT ONLY RELATED TO CONTENT INSIDE OF THAT FOLDER --
-- ANY CONTENT THAT IS USED OUTSIDE BUT IS INSIDE THIS FOLDER WILL BE PRINTED OUT --
-- WARNING2: THIS SCRIPT IS MEANT FOR REMOVING MATERIALS FOR MODELS (MDL FILES), ANY KINDS OF ICONS AND OTHER MATERIALS THEY WILL BE PRINTED OUT --
local Path = "addons/content_folder_name/"


-- END OF CONFIG (ANYTHING BELOW THIS LINE IS PURELY CODE AND SHOULDNT BE TOUCHED) --


-- SeekPos1 is used for grabbing the names of the materials
-- SeekPos2 is used for grabbing the directories of the materials
local SeekPos1 = 4 * 3 + 64 + 4 + 12 * 6 + 4 * 13
local SeekPos2 = 4 * 3 + 64 + 4 + 12 * 6 + 4 * 15
local file_Find = file.Find
local file_Open = file.Open
local file_Exists = file.Exists
local PathWithMats = Path .. "materials/"

local function ReadString(file)
    local str = ""
    while true do
        local char = file:Read(1)
        if char:byte() == 0 or file:EndOfFile() then
            break
        end

        -- If it's a \ then change it to /
        if char == "\\" then
            str = str .. "/"

            continue
        end

        str = str .. char
    end

    return str
end

local ModelsCache = {}
local function ParseMDL(open, name)
    local Names = {}

    open:Seek(SeekPos1)
    local Count = open:ReadLong()
    local Offset = open:ReadLong()
    
    for i = 1, Count do
        open:Seek( Offset + ( 64 * ( i - 1 ) ) )
        open:Skip( open:ReadLong() - 4 )

        Names[i] = ReadString(open)
    end

    open:Seek(SeekPos2)
    local Dir_Count = open:ReadLong()
    local Dir_Offset = open:ReadLong()
    open:Seek(Dir_Offset)
    local ints = {}
    for i = 1, Dir_Count do
        ints[i] = open:ReadLong()
    end

    local Found = {}
    do
        local FCount = 0
        -- We grabbed all of the material names from the mdl
        -- Now were grabbing all of the directories --
        -- Keep in mind that the directories dont match the amount of material names --
        -- So you have to store a string for each material name with that directory --
        -- Then use that string to remove a key from the CachedMaterials table --
        -- Then printing out the entire CachedMaterials table will give out all of the materials that need to be removed --
        -- It's probably a good idea to put a file.Exists in there to check if that material actually exists --
        -- But its kinda pointless to do because it just slows down the entire compilation, unless you actually need to be 100% accurate with the mdl materials --
        for i = 1, Dir_Count do
            if not ints[i] then
                --[[
                    Couldn't read the directory for this material --
                    In HLMV it has a problem reading the directory too because of missing VMT --
                    Not sure if related
                ]]
                break
            end
            open:Seek(ints[i])

            local dir = ReadString(open)
            for i = 1, Count do
                FCount = FCount + 1
                Found[FCount] = (PathWithMats .. dir .. Names[i]):Trim():lower()

                --[[
                    local full = (PathWithMats .. dir .. Names[i]):Trim()
                    if file_Exists(full .. ".vmt", "GAME") then
                        FCount = FCount + 1
                        Found[FCount] = full
                    end
                    if file_Exists(full .. ".vtf", "GAME") then
                        FCount = FCount + 1
                        Found[FCount] = full
                    end
                ]]
            end
        end
    end

    ModelsCache[name] = Found

    open:Close()
end

local function IterMDLS(files, folders, str)
    for i = 1, #files do
        local fname = files[i]
        if fname:match(".mdl") then
            local fpath = str .. fname
            local file = file_Open( fpath, "r", "GAME" )
            if file then
                ParseMDL(file, fpath)
            end
        end
    end

    for i = 1, #folders do
        local full = str .. folders[i]

        local f1, f2 = file_Find(full .. "/*", "GAME")
        IterMDLS(f1, f2, full .. "/")
    end
end

local CachedMaterials = {}
local function IterMats(files, folders, str)
    for i = 1, #folders do
        local folderpath = str .. folders[i]

        local files, folders = file_Find(folderpath .. "/*", "GAME")
        IterMats(files, folders, folderpath .. "/")
    end

    for i = 1, #files do
        local txt = (str .. files[i])

        CachedMaterials[txt:sub(1, #txt - 4):Trim():lower()] = true
    end
end

local function SearchBoth()
    do
        -- Iterate over mdl files in given path --
        local mdl_files, mdl_folders = file_Find(Path .. "models/*", "GAME")

        IterMDLS(mdl_files, mdl_folders, Path .. "models/")
    end

    do
        -- Iterate over material files in given path --
        local mat_files, mat_folders = file_Find(PathWithMats .. "*", "GAME")
        IterMats(mat_files, mat_folders, PathWithMats)
    end
end

SearchBoth()

local Before = table.Count(CachedMaterials)
do
    for k,v in pairs(ModelsCache) do
        for i = 1, #v do
            CachedMaterials[v[i]] = nil
        end
    end
end

print("\n---------------------------------------------------")
print("-- Materials to be removed --\n")
for k in pairs(CachedMaterials) do
    print(k)
end
print("\n")
print("Total Materials: " .. Before)
print("Materials for removal: " .. table.Count(CachedMaterials))