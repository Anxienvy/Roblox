-- // Services
local Players = game:GetService("Players")

-- // Variables
local localPlayer = Players.LocalPlayer

local Handler = {}
do
    Handler.__index = Handler

    function Handler.new(data)
        data = data or {}

        local self = setmetatable({}, Handler)
        self.commands = data.commands or {}
        self.prefix = data.prefix or {"/", "/e ", ":", ";"}

        return self
    end

    function Handler.addCommand(self, data)
        data.handler = self
        table.insert(self.commands, data)
    end

    function Handler.execute(self, message)
        message = string.gsub(string.lower(message), "^%s*(.-)%s*$", "%1")

        local prefix
        for _, prefix_ in ipairs(self.prefix) do
            if prefix_ ~= "" and string.sub(message, 1, #prefix_) == prefix_ then
                local strArea = string.sub(message, 1, #prefix_ + 2)
                if string.find(strArea, "%s") then
                    message = string.gsub(string.gsub(strArea, "%s", ""), prefix_, "")
                else
                    message = string.gsub(message, prefix_, "")
                end

                prefix = prefix_
                break
            end
        end

        if prefix ~= nil then
            local args = string.split(message, " ")
            if #args == 1 and args[1] == "" then
                args = {}
            end

            local command
            for _, commands in ipairs(self.commands) do
                if commands.name == args[1] or table.find(commands.alias, args[1]) then
                    command = commands
                    break
                end
            end

            if command ~= nil then
                command.callback(table.remove(args, 1), args)
            end

        end
    end

    function Handler.listen(self)
        if getgenv().listener then
            getgenv().listener:Disconnect()
        end

        getgenv().listener = localPlayer.Chatted:Connect(function(message)
            self:execute(message)
        end)
    end
end

local Command = {}
do
    Command.__index = Command

    function Command.new(handler, data)
        local self = setmetatable({}, Command)

        self.name = data.name
        self.alias = data.alias or {}
        self.handler = nil
        self.callback = data.callback or function() end

        if handler ~= nil then
            self.handler = handler
            self.handler:addCommand(self)
        end

        return self
    end
end

return Handler, Command
