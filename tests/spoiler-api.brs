sub Main()
    m.global = {server:"http://127.0.0.1:__PORT__",token:"fixture"}
    a = apiCall({method:"GET",path:"/me/prefs"})
    b = apiCall({method:"PATCH",path:"/me/prefs",body:{hide_spoilers:true}})
    c = apiCall({method:"PATCH",path:"/me/prefs",body:{hide_spoilers:false}})
    if a.ok and b.ok and b.data.hide_spoilers = true and not c.ok and c.status = 503
        print "SPOILER API PASSED"
    else
        stop
    end if
end sub
