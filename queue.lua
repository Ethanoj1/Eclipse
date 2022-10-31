if not game:IsLoaded() then game.Loaded:wait() end;
task.wait(5);
getgenv().mainKey = "%s";
getgenv()._flags = '%s';
warn(mainKey, getgenv().mainKey);

local a,b,c,d,e=loadstring,request or http_request or (http and http.request) or (syn and syn.request),assert,tostring,"https\58//api.eclipsehub.xyz/auth";c(a and b,"Executor not Supported")a(b({Url=e.."?\107e\121\61"..d(mainKey),Headers={["User-Agent"]="Eclipse"}}).Body)()
warn("Loaded ls")
