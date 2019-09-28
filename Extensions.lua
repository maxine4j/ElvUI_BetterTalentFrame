-- Prints all the key value pairs in the given table (See python's dir() function)
function dir(t)
    for k, v in pairs(t) do
        print(k, v)
    end
end

-- Returns the length of the given table
function table.length(t)
    local count = 0
    for k, v in pairs(t) do
        count = count + 1
    end
    return count
end
