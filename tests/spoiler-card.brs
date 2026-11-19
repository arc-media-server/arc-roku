sub Main()
    m.global = {hideSpoilers:true}
    m.picture = {}
    m.face = {}
    m.line1 = {}
    m.line2 = {}
    m.top = {width:0,height:0,itemContent:{style:"thumb",title:"Episode One",line2:"E1",HDPosterUrl:"/still",safeArt:"/show",spoilerEligible:true}}
    onContent()
    if m.picture.uri <> "/show" then stop
    m.global.hideSpoilers = false
    onContent()
    if m.picture.uri <> "/still" then stop
    m.top.itemContent.spoilerEligible = false
    m.global.hideSpoilers = true
    onContent()
    if m.picture.uri <> "/still" then stop
    print "SPOILER CARD PASSED"
end sub
