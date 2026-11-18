sub Main()
    m.global = { server: "http://127.0.0.1:__PORT__", token: "scratch" }
    saved = apiCall(ratingRequest("a/b", 9))
    cleared = apiCall(ratingRequest("a/b", 0))
    refused = apiCall(ratingRequest("a/b", 1))
    if saved.ok and saved.status = 204 and cleared.ok and cleared.status = 204 and not refused.ok and refused.status = 403
        print "RATING API PASSED"
    else
        print "RATING API FAILED"
    end if
end sub
