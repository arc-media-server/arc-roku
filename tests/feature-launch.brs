sub testLaunchProfile()
    alex = { id: "a" }
    jordan = { id: "b" }
    status = { profile: alex, profiles: [alex, jordan] }
    check(launchProfile(status, "", true) = invalid, "cold launch shows picker")
    eq(launchProfile(status, "b", false).id, "a", "resume keeps profile")
    eq(launchProfile(status, "b", true).id, "b", "automatic sign-in can switch profile")
    jordan.has_pin = true
    check(launchProfile(status, "b", true) = invalid, "PIN opens picker")
    check(launchProfile(status, "missing", true) = invalid, "deleted profile opens picker")
    status.profiles = [alex]
    eq(launchProfile(status, "", true).id, "a", "single unlocked profile stays selected")
end sub
