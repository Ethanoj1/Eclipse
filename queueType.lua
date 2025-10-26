if not game:IsLoaded() then 
  print("Waiting on game load...")
  game.Loaded:Wait() 
  print("Game loaded...")
end;
task.wait(5);
getgenv().mainKey = "%s";
getgenv()._flags = '%s';

local a,b,c,d,e=loadstring,request or http_request or (http and http.request) or (syn and syn.request),assert,tostring,"https\58//api.eclipsehub.xyz/auth";c(a and b,"Executor not Supported")a(b({Url=e.."?\107e\121\61"..d(mainKey).."\38\116\61%d",Headers={["User-Agent"]="Eclipse"}}).Body)()
