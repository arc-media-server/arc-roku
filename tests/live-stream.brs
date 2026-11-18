' Native simulator transport integration: server remains open until AsyncCancel.
sub Main()
    state = liveState()
    port = CreateObject("roMessagePort")
    for attempt = 1 to 2
        transfer = liveTransfer("http://127.0.0.1:18419", "fixture-token", state.cursor, port)
        if not transfer.AsyncGetSSEvents() then stop
        clock = CreateObject("roTimespan")
        found = false
        while not found and clock.TotalMilliseconds() < 6000
            event = wait(100, port)
            if type(event) = "roSSEvent"
                liveEvent(state, event.GetEvent(), event.GetData(), event.GetId(), clock.TotalMilliseconds())
                if event.GetEvent() = "invalidate"
                    found = state.pending.DoesExist("profile") and state.cursor = "fixture-2"
                end if
            end if
        end while
        transfer.AsyncCancel()
        if not found
            print "FAIL stream did not deliver a hint while open"
            return
        end if
    end for
    print "STREAM PASSED"
end sub
