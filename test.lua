-- Test your connection to Eclipse Hub servers. Note: This is NOT the loadstring.
print("🔃 Starting test...")
local start = os.clock();
getgenv().mainKey = "nil";

xpcall(function()
    local a,b,c,d,e=loadstring,request or http_request or (http and http.request) or (syn and syn.request),assert,tostring,"https\58//api.eclipsehub.xyz/auth";
    if not a or not b then
        return warn("❌ Test failed due to compatability issue:", a, b)
    end
    local f = b({Url=e.."?\107e\121\61"..d(mainKey),Headers={["User-Agent"]="Eclipse"}});
    print("Response:", f.Success, f.StatusCode);
    if not f.Body:find("startup") then
        setclipboard(f.Body);
        return warn("❌ Test failed due to invalid body:", f.Body);
    end
    local g, h = pcall(a, f.Body);
    if not g then
        return warn("❌ Test failed due to syntax error:", h);
    end
    print("✅ Test passed.", h)
end, function(err)
    warn("❌ Test failed due to error:", err);
end)

print(("🔃 Ending test, took %.2f"):format(os.clock() - start));