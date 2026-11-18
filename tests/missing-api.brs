sub Main()
    m.global = { server: "http://127.0.0.1:__PORT__", token: "fixture-only" }
    a = apiCall({method: "GET", path: seasonsPath("a/b", false)})
    b = apiCall({method: "GET", path: seasonsPath("a/b", true)})
    if a.ok and b.ok and b.data.seasons.Count() = 1
        print "MISSING API PASSED"
    else
        stop
    end if
end sub
