sub Main()
    m.global = {hideSpoilers:true}
    m.picture = {}
    m.blank = {}
    m.face = {}
    m.line1 = {}
    m.line2 = {}
    m.top = {width:0,height:0,itemContent:{style:"thumb",title:"Episode One",line2:"E1",HDPosterUrl:"/still",safeArt:"/show",spoilerEligible:true,available:false}}
    onContent()
    if m.picture.uri <> "/show" then stop
    if m.picture.opacity <> 0.45 or m.blank.opacity <> 0.45 then stop
    m.top.itemContent.available = true
    onContent()
    if m.picture.uri <> "/show" or m.picture.opacity <> 1 or m.blank.opacity <> 1 then stop
    m.global.hideSpoilers = false
    onContent()
    if m.picture.uri <> "/still" then stop
    m.top.itemContent.spoilerEligible = false
    m.global.hideSpoilers = true
    onContent()
    if m.picture.uri <> "/still" then stop
    print "SPOILER CARD PASSED"
end sub
