sub Main()
    for each id in ["film 1", "empty"]
        transfer = CreateObject("roUrlTransfer")
        transfer.SetUrl(absoluteUrl("http://127.0.0.1:18431", prerollPath(id)))
        transfer.AddHeader("Authorization", "Bearer fixture")
        clips = prerollClips(ParseJson(transfer.GetToString()))
        if id = "film 1"
            if clips.Count() <> 2 then stop
            if clips[0].url <> "/api/preroll/0" or clips[1].url <> "/api/preroll/1" then stop
        else
            if clips.Count() <> 0 then stop
        end if
    end for
    print "PREROLL SERVER PASSED"
end sub
