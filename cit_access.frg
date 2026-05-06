#lang forge/temporal
open "cit_data.frg"

option run_sterling "layout.cnd"
option run_sterling "vis.js"

pred staysInRoomForever[r: Room] {
    always(Person.loc = r)
}

// Returns true iff l is at least min
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
    Person.loc = d.to // For simplicity, we assume all doors are always open in the "backwards direction", 
    // e.g., leaving the CIT lobby as opposed to entering it does not require an ID swipe
}

pred step[r: Room, r1: Room, t: AccessTime] {
    Person.loc = r

    some d : Door | {
        d.from = r
        d.to = r1
        canTraverse[d, t]
    }
    Person.loc' = r1
}

pred reachable[start: Room, end: Room, t: AccessTime] {
    Person.loc = start 
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

pred canUseDoor[d: Door, t: AccessTime, l: AccessLevel] {
    atLeast[l, d.accessible[t]]
}

// Builds a relation r where r1 -> r2 is in r if and only if you
// can get from r1 to r2 (with one door) at the given AccessLevel and AccessTime
fun edges[t: AccessTime, l: AccessLevel]: Room -> Room {
  { r1, r2: Room |
    some d: Door | {
      (
        d.from = r1 and d.to = r2 and canUseDoor[d, t, l]
      )
      or
      (
        d.to = r1 and d.from = r2
      )
    }
  }
}

pred reachableWithAccessLevel[start, end: Room, t: AccessTime, l: AccessLevel] {
  end in start.*(edges[t, l])
}

pred validEquivClasses[start: Room, t: AccessTime] {
    buildMap
    
    // Disjointness and completeness: all rooms are in exactly one equivalence class
    all r: Room | {
        (r in EquivClasses.security and r not in (EquivClasses.profAndHigher + EquivClasses.TAandHigher + EquivClasses.studentAndHigher + EquivClasses.publicAndHigher)) or
        (r in EquivClasses.profAndHigher and r not in (EquivClasses.security + EquivClasses.TAandHigher + EquivClasses.studentAndHigher + EquivClasses.publicAndHigher)) or
        (r in EquivClasses.TAandHigher and r not in (EquivClasses.profAndHigher + EquivClasses.security + EquivClasses.studentAndHigher + EquivClasses.publicAndHigher)) or
        (r in EquivClasses.studentAndHigher and r not in (EquivClasses.profAndHigher + EquivClasses.TAandHigher + EquivClasses.security + EquivClasses.publicAndHigher)) or
        (r in EquivClasses.publicAndHigher and r not in (EquivClasses.security + EquivClasses.profAndHigher + EquivClasses.TAandHigher + EquivClasses.studentAndHigher))
    }

    // All rooms are in the appropriate equivalence class
    all r: Room | {
        r in EquivClasses.security <=> {
            reachableWithAccessLevel[start, r, t, Security]
            not reachableWithAccessLevel[start, r, t, Prof]
        }

        r in EquivClasses.profAndHigher <=> {
            reachableWithAccessLevel[start, r, t, Prof]
            not reachableWithAccessLevel[start, r, t, TA]
        }

        r in EquivClasses.TAandHigher <=> {
            reachableWithAccessLevel[start, r, t, TA]
            not reachableWithAccessLevel[start, r, t, Student]
        }

        r in EquivClasses.studentAndHigher <=> {
            reachableWithAccessLevel[start, r, t, Student]
            not reachableWithAccessLevel[start, r, t, Public]
        }

        r in EquivClasses.publicAndHigher <=> {
            reachableWithAccessLevel[start, r, t, Public]
        }
    }
    //In each equivalence class, all rooms cannot be accessed by a lower level
}


// traces to see steps of where a student can go
// run {
//     traces[Sciences_Park, Room477, BusinessHours, Student]
// } for exactly 41 Door, 31 Room, 5 Int

// equivalence classes from sciences_park on business hours
// run {
//     validEquivClasses[Sciences_Park, BusinessHours]
// } for exactly 41 Door, 31 Room, 5 Int


// // equivalence classes from sciences_park on weekday off hours
// run {
//     validEquivClasses[Sciences_Park, OffHoursWeekday]
// } for exactly 41 Door, 31 Room, 5 Int

// equivalence classes from first floor lobby on weekday off hours
// run {
//     validEquivClasses[Lobby_F1, OffHoursWeekday]
// } for exactly 41 Door, 31 Room, 5 Int // < 1 min

// following workflow: traces to show how a member of public could get to room 
run {
    traces[Lobby_F3, Room510, OffHoursWeekday, Public]
} for exactly 41 Door, 31 Room, 5 Int

// equivalence classes from 3rd floor lobby on weekday off hours
run {
    validEquivClasses[Lobby_F3, OffHoursWeekday]
} for exactly 41 Door, 31 Room, 5 Int
