sub Main()
    m.global = {hideSpoilers:false,spoilerRevision:0,profile:{id:"p"},token:"fixture"}
    m.requests = []
    loadSpoilerPrefs()
    first = m.requests[0].tag
    check(m.global.hideSpoilers, "conceal while loading")
    loadSpoilerPrefs()
    second = m.requests[1].tag
    onSpoilerPrefs(eventFor({ok:true,data:{hide_spoilers:false},tag:first}))
    check(m.global.hideSpoilers, "old request ignored")
    onSpoilerPrefs(eventFor({ok:false,tag:second}))
    check(m.global.hideSpoilers, "failed load remains conservative")
    onSpoilerPrefs(eventFor({ok:true,data:{hide_spoilers:false},tag:second}))
    check(not m.global.hideSpoilers, "current profile setting applied")
    m.global.profile = {id:"other"}
    loadSpoilerPrefs()
    onSpoilerPrefs(eventFor({ok:true,data:{hide_spoilers:false},tag:second}))
    check(m.global.hideSpoilers, "old profile response ignored")
    print "SPOILER PROFILE PASSED"
end sub
sub callApi(method as string,path as string,body as dynamic,callback as string,tag=invalid as dynamic)
    m.requests.Push({method:method,path:path,body:body,tag:tag})
end sub
function eventFor(data as object) as object
    return {data:data,getData:function() as object
        return m.data
    end function}
end function
sub check(ok as boolean,message as string)
    if not ok then print "SPOILER PROFILE FAILED: ";message:stop
end sub
