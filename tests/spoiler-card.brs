sub Main()
    m.global = {hideSpoilers:true}
    m.picture = {}
    m.blank = {}
    m.face = {}
    m.line1 = {}
    m.line2 = {}
    m.overview = {}
    m.logo = {}
    m.logoTitle = {}
    m.top = {width:0,height:0,itemContent:{style:"thumb",title:"Episode One",line2:"E1",HDPosterUrl:"/still",safeArt:"/show",spoilerEligible:true,available:false,showOverview:true,overview:"Episode synopsis"}}
    onContent()
    if m.picture.uri <> "/show" or m.overview.visible or m.overview.text <> "" then stop
    if m.picture.opacity <> 0.45 or m.blank.opacity <> 0.45 then stop
    m.top.itemContent.available = true
    onContent()
    if m.picture.uri <> "/show" or m.picture.opacity <> 1 or m.blank.opacity <> 1 then stop
    m.global.hideSpoilers = false
    onContent()
    if m.picture.uri <> "/still" or not m.overview.visible or m.overview.text <> "Episode synopsis" then stop
    m.top.itemContent.spoilerEligible = false
    m.global.hideSpoilers = true
    onContent()
    if m.picture.uri <> "/still" then stop
    if not m.overview.visible then stop
    m.top.itemContent.showOverview = false
    onContent()
    if m.overview.visible or m.overview.text <> "" then stop
    testSeasonArt()
    print "SPOILER CARD PASSED"
end sub

sub testSeasonArt()
    ep = { id: "e2", title: "Episode Two", kind: "episode", images: { primary: "/still", series_primary: "/series", season_primary: "/season", series_backdrop: "/wide" } }
    card = { item: ep }
    node = cardFields()
    fillCard(node, card, "poster", true)
    if node.HDPosterUrl <> "/season" or node.safeBackdrop <> "/wide?size=full" then stop
    m.top.itemContent = node
    onContent()
    if m.picture.uri <> "/season" then stop

    fillCard(node, card, "poster", false)
    if node.HDPosterUrl <> "/series" then stop
    fillCard(node, card, "thumb", true)
    if node.HDPosterUrl <> "/still" or node.safeArt <> "/wide" then stop
    fillCard(node, card, "backdrop", true)
    if node.HDPosterUrl <> "/wide" then stop
    ep.images.Delete("season_primary")
    fillCard(node, card, "poster", true)
    if node.HDPosterUrl <> "/series" or node.safeArt <> "/series" then stop

    group = { item: { id: "s", title: "Series", kind: "series", images: { primary: "/series" } }, season: 2, seasonPoster: "/season" }
    fillCard(node, group, "poster", true)
    if node.HDPosterUrl <> "/season" then stop
    fillCard(node, group, "poster", false)
    if node.HDPosterUrl <> "/series" then stop
end sub

function imageUrl(path as dynamic) as string
    if path = invalid then return ""
    return path
end function
