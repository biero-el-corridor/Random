hvtlp = Proto("HVTLP", "Hill Valley Traffic Light")

-- observed commands
local COMMANDS = {
    [0x10] = "ID",
    [0x11] = "Address",
    [0x12] = "Status",
    [0x14] = "Durations"
}

hvtlp.fields.magic = ProtoField.string("hvtlp.magic", "Magic")
hvtlp.fields.version = ProtoField.uint8("hvtlp.version", "Version")
hvtlp.fields.type = ProtoField.uint8("hvtlp.type", "Type", base.DEC, {[1] = "Request", [2] = "Response"})
hvtlp.fields.command = ProtoField.uint8("hvtlp.command", "Control Code", base.HEX, COMMANDS)

function hvtlp.dissector(buffer, pinfo, tree)

    if (buffer:len() < 10) then return end

    local magic = buffer(0,5):string()
    if magic ~= "1.2GW" then return end

    local request = buffer(6,1):uint()
    local cmd = buffer(7,1):uint()

    pinfo.cols.protocol = hvtlp.name
    local subtree = tree:add(hvtlp, buffer(), "HillValley Traffic Light")
    subtree:add(hvtlp.fields.magic, buffer(0,5))
    subtree:add(hvtlp.fields.version, buffer(5,1))
    subtree:add(hvtlp.fields.type, buffer(6,1))
    subtree:add(hvtlp.fields.command, buffer(7,1))

    if COMMANDS[cmd] ~= nil then
        pinfo.cols.info = COMMANDS[cmd] .. " " .. (request == 1 and "Request" or "Response")
    else
        pinfo.cols.info = string.format("Unknown cmd [%02x] ", cmd) .. (request == 1 and "Request" or "Response")
    end

end

tcp_table = DissectorTable.get("tcp.port"):add(54321, hvtlp)