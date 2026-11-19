sub Main()
    m.global = {hideSpoilers:false,spoilerRevision:0,profile:{id:"p"}}
    m.prefs = {hide_spoilers:false}
    m.requests = []
    m.note = {text:""}
    m.top = {note:m.note,findNode:function(id as string) as object
        return m.note
    end function}
    saveSpoilers()
    check(m.requests.Count() = 1 and m.requests[0].body.hide_spoilers, "save only requested preference")
    check(not m.global.hideSpoilers and not m.prefs.hide_spoilers, "no optimistic reveal/change")
    saveSpoilers()
    check(m.requests.Count() = 1, "duplicate save bounded")
    onSpoilersSaved(eventFor({ok:false,tag:{profile:"p"}}))
    check(not m.prefs.hide_spoilers and m.note.text <> "", "failed save retains value and explains retry")
    saveSpoilers()
    onSpoilersSaved(eventFor({ok:true,data:{hide_spoilers:true},tag:{profile:"p"}}))
    check(m.prefs.hide_spoilers and m.global.hideSpoilers, "successful save publishes choice")
    onSpoilersSaved(eventFor({ok:true,data:{hide_spoilers:false},tag:{profile:"other"}}))
    check(m.global.hideSpoilers, "old profile response ignored")
    print "SPOILER SETTINGS PASSED"
end sub
sub callApi(method as string,path as string,body as dynamic,callback as string,tag=invalid as dynamic)
    m.requests.Push({method:method,path:path,body:body,tag:tag})
end sub
sub draw()
end sub
function eventFor(data as object) as object
    return {data:data,getData:function() as object
        return m.data
    end function}
end function
sub check(ok as boolean,message as string)
    if not ok then print "SPOILER SETTINGS FAILED: ";message:stop
end sub
