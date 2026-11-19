sub Main()
    m.global = {hideSpoilers:true}
    m.next = {id:"next",kind:"episode",images:{primary:"/still",series_backdrop:"/show"}}
    m.poster = {}
    m.top = {poster:m.poster,findNode:function(id as string) as object
        return m.poster
    end function}
    setUpNextArtwork()
    if m.poster.uri <> "/show" then stop
    m.global.hideSpoilers = false
    setUpNextArtwork()
    if m.poster.uri <> "/still" then stop
    m.next = {id:"next",kind:"episode",images:{primary:"/still"}}
    m.global.hideSpoilers = true
    setUpNextArtwork()
    if m.poster.uri <> "" then stop
    print "SPOILER UP NEXT PASSED"
end sub
sub shareSignIn(posters as object)
end sub
function imageUrl(path as dynamic) as string
    if path = invalid then return ""
    return path
end function
