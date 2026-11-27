' Exercise the production player sync on a native-player stand-in without hitting a user's server.
sub Main()
    check(roomCode("abcd-2345") = "ABCD2345", "normalize an invite")
    check(roomCode("ABCD-01IO") = "" and roomCode("ABC") = "", "reject ambiguous and short codes")
    check(estimatedServerAtReceipt(1795820732193#, 1795820732123#, 130) = 1795820732223#, "clock sample keeps epoch precision and removes server processing time")

    room = { id: "test-room", item_id: "episode-1", revision: 4, generation: 2, state: "waiting", at_ms: 10000, position_ms: 55000, rate: 1, server_time_ms: 10000, available: true, participants: [] }
    check(roomPosition(room, 11200) = 55000, "waiting freezes the shared position")
    check(not newerRoom(room, { id: room.id, revision: 3 }), "older responses cannot undo a room update")
    check(not newerRoom(room, { id: room.id, revision: 4, server_time_ms: 9000 }), "older snapshots at the same revision are ignored")

    m.closed = false
    m.top = { params: { id: "episode-1" } }
    m.together = { report: {} }
    m.roomSnapshot = { room: room, serverNow: 10000, offline: false }
    m.roomNotice = { label: {}, getChild: function(index as integer) as object
        return m.label
    end function }
    m.roomClock = CreateObject("roTimespan")
    m.roomSeekClock = CreateObject("roTimespan")
    m.roomSeek = -1
    m.appliedGeneration = 1
    m.errorLabel = { visible: false }
    m.plan = { hls: true, offset_ms: 40000, duration_ms: 180000 }
    m.video = { state: "playing", position: 11, duration: 50 }
    syncRoomPlayback()
    check(m.roomNotice.visible and m.video.control = "pause", "an unready room pauses the player")
    check(m.video.seek = 15, "shared seek uses the HLS clock locally")
    beat = roomHeartbeat(room, m.together.report)
    check(not beat.ready and beat.state = "waiting", "seek must land before this generation is ready")

    m.video.state = "paused"
    m.video.position = 15
    syncRoomPlayback()
    beat = roomHeartbeat(room, m.together.report)
    check(beat.ready and beat.generation = 2 and beat.position_ms = 55000, "heartbeats send the ready generation and file position")
    check(not roomHeartbeat(room, { itemId: "another", position: 55000, generation: 2, ready: true }).ready, "another title cannot release the barrier")

    room.state = "playing"
    check(roomPosition(room, 11200) = 56200, "playing advances from the authority timestamp")
    syncRoomPlayback()
    check(m.video.control = "resume" and not m.roomNotice.visible, "playing room resumes the player")
    userSeek(61000)
    check(m.together.command.action = "seek" and m.together.command.position_ms = 61000 and m.video.seek = 15, "user seek sends a room command without a local seek")

    m.video.state = "buffering"
    syncRoomPlayback()
    check(not m.together.report.ready and m.together.command.action = "heartbeat", "buffering makes this participant unready immediately")
    room.available = false
    room.Delete("item_id")
    syncRoomPlayback()
    check(m.top.action.go = "back", "a redacted title exits the player")
    print "TOGETHER PLAYER PASSED"
end sub

function tr(text as string) as string
    return text
end function

sub check(ok as boolean, message as string)
    if not ok then print "TOGETHER PLAYER FAILED: "; message: stop
end sub
