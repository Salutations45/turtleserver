

-- SaluYolo

-- Imagine
-- regarder
-- le
-- code
-- d'un
-- programme...


-- Control server address
local API = "http://localhost:8000"

-- Init
os.setComputerLabel("Salut")
local f = fs.open("key","r")
local key
if f then
	key = f.readLine()
	f.close()
	print("started...")
else
	math.randomseed(os.time())
	key = math.random(1000000)
	local file = fs.open("key", "w")
	file.write(key.."")
	file.close()
	print("Reviens dans quelques minutes...")
end

-- Convert data to human readable string
function toString2(data, n)
	local t = type(data)
	if t=="number" or t=="string" then
		return ""..data
	elseif t=="table" then
		if n<0 then
			return "{...}"
		end
		local msg = "{"
		for k, v in pairs(data) do
			msg = msg..toString2(k,n-1)..":"..toString2(v,n-1)..", "
		end
		return msg.."}"
	elseif t=="nil" then
		return "nil"

	elseif t=="boolean" then
		if(data) then
			return "true"
		else
			return "false"
		end
	else
		return t
	end
end


local receivedEvents = {}

-- Loop checking if turtle has any program to run or events to send to server
function instructionLoop()
	while true do
		local res = http.get(API.."/prog/"..key)
		if res then
			local code = res.readAll()
			if code then
				local func = loadstring(code)
				if func then
					setfenv(func, getfenv())
					local success, data = pcall(func)
					local msg = "false "
					if success then
						msg = "true "
					end
					if data then
						msg = msg.." data: "..toString2(data, 3)
					end
					local r = http.post(API.."/return/"..key, msg)
					if r then
						r.close()
					end
				end
			end
		end

		if next(receivedEvents) then
			http.post(API.."/event/"..key, toString2(receivedEvents, 3))
			receivedEvents = {}
		end
		sleep(5)
	end
end

-- Loop checking if any interesting events are received
function eventLoop()
	while true do
		local event, p1, p2, p3, p4, p5 = os.pullEvent();

		local ignore = false
		if event == "http_success" then ignore = true end
		if event == "http_failure" then ignore = true end
		if event == "timer" then ignore = true end
		if event == "task_complete" then ignore = true end
		if event == "turtle_response" then ignore = true end

		if not ignore then 
			local ev = {}
			ev["event"] = event
			ev["p1"] = p1
			ev["p2"] = p2
			ev["p3"] = p3
			ev["p4"] = p4
			ev["p5"] = p5

			table.insert(receivedEvents, ev);
		end

	end
end

-- Run loops
parallel.waitForAny(instructionLoop, eventLoop)

