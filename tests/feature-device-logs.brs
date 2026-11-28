sub testDeviceLogs()
    stamp = 1795420800000&
    secret = "https://private.test/cast?token=secret-fixture&pin=1234"
    safe = projectDeviceLogs([{time_ms: stamp, level: "warn", event: "request_failed", token: secret}, {time_ms: stamp, level: "warn", event: secret}])
    eq(safe.Count(), 1, "only known diagnostic events")
    eq(safe[0].event, "request_failed", "the safe event survives")
    check(Instr(1, FormatJson(safe), "private.test") = 0, "diagnostics never include raw strings")
end sub
