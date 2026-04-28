#lang forge/temporal
open "cit_data.frg"

option run_sterling "vis.js"

pred staysInRoomForever[r: Room] {
    always(Person.loc = r)
}

// Returns true iff l is at least min
// 
pred atLeast[l: AccessLevel, min: AccessLevel] {
  min = Public
  or l = min
  or (min = Student and l in Student + TA + Prof + Security)
  or (min = TA and l in TA + Prof + Security)
  or (min = Prof and l in Prof + Security)
  or (min = Security and l = Security)
}

pred canTraverse[d: Door, t: AccessTime] {
    (Person.loc = d.from and atLeast[Person.level, d.accessible[t]])
    or
    Person.loc = d.to
}

pred step[r: Room, r1: Room, t: AccessTime] {
    // t = t'

    // d = Door between r and r1
    // Person must be at r
    // Person' must be at r1
    // canTraverse(d, t)
    
    Person.loc = r
    // TODO check whether door fields remain constant
    some d : Door | {
        d.from = r
        d.to = r1
        canTraverse[d, t]
    }

    Person.loc' = r1
}

pred reachable[start: Room, end: Room, t: AccessTime] {
    Person.loc = start // TODO verify this
    eventually(Person.loc = end)
}

// Traces to get from one room to another at a fixed AccessTime, AccessLevel
pred traces[start: Room, end: Room, t: AccessTime, l: AccessLevel] {
    buildMap
    Person.level = l
    reachable[start, end, t]
    always(staysInRoomForever[end] or (
        some r1: Room | {
            step[Person.loc, r1, t] 
        }
    ))
}

run {
    traces[Sciences_Park, Lobby_F2, BusinessHours, Student]
} for exactly 8 Door, 7 Room, 5 Int