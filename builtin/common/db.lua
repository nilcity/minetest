db = { user = { } }

db.conn = hiredis.connect("localhost", "8808");
db.conn:command("AUTH", "root");

function db.user.find( name ) 
    local res = db.conn:command("HGETALL", "user:" .. name);
    if(res == nil) then
        return nil;
    end

    local datalen = #res;
    if(datalen < 2) then
        return nil;
    end

    local tmpUser = {}
    for i = 2, datalen, 2 do
        tmpUser[res[i - 1]] = res[i];
    end

    return tmpUser;
end

function db.user.insert(data) 
    assert(db.conn:command("MULTI") == hiredis.status.OK)

    for k, v in pairs(data) do
        print("multi: " .. k .. '|' .. v);
        assert(db.conn:command("HSET", "user:" .. data.name, k, v));
    end

    local t = assert(db.conn:command("EXEC"))

    return t[1] == hiredis.status.OK;
end

function db.user.update(name, key, value)
    local t = db.conn:command("HSET", "user:" .. name, key, value);

    return t;
end

function db.user.delete() 

end
