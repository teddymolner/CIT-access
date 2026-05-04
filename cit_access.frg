#lang forge/temporal
open "cit_data.frg"

option run_sterling "layout.cnd"
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

pred canUseDoor[d: Door, t: AccessTime, l: AccessLevel] {
    atLeast[l, d.accessible[t]]
}

// Builds a relation r where r1 -> r2 is in r if and only if you
// can get from r1 to r2 (with one door) at the given accesslevel and accesstime

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

pred validEquivClasses[t: AccessTime] {
    buildMap
    // TODO test case: public should just be sciences park
    // All rooms are in exactly one equivalence class
    all r: Room | {
        (r in EquivClasses.security and r not in (EquivClasses.profAndHigher + EquivClasses.TAandHigher + EquivClasses.studentAndHigher + EquivClasses.publicAndHigher)) or
        (r in EquivClasses.profAndHigher and r not in (EquivClasses.security + EquivClasses.TAandHigher + EquivClasses.studentAndHigher + EquivClasses.publicAndHigher)) or
        (r in EquivClasses.TAandHigher and r not in (EquivClasses.profAndHigher + EquivClasses.security + EquivClasses.studentAndHigher + EquivClasses.publicAndHigher)) or
        (r in EquivClasses.studentAndHigher and r not in (EquivClasses.profAndHigher + EquivClasses.TAandHigher + EquivClasses.security + EquivClasses.publicAndHigher)) or
        (r in EquivClasses.publicAndHigher and r not in (EquivClasses.security + EquivClasses.profAndHigher + EquivClasses.TAandHigher + EquivClasses.studentAndHigher))
    }
   // all rooms are accessible at the level it says it will be at
    all r: Room | {
        r in EquivClasses.security => {
            // r is reachable from sciencespark at time t with accesslevel security
            reachableWithAccessLevel[Sciences_Park, r, t, Security]
            and not reachableWithAccessLevel[Sciences_Park, r, t, Prof]
            and not reachableWithAccessLevel[Sciences_Park, r, t, Student]
            and not reachableWithAccessLevel[Sciences_Park, r, t, Public]
            and not reachableWithAccessLevel[Sciences_Park, r, t, TA]
            // r is not reachable from sciencespark at time t with any access level below security
        }

        r in EquivClasses.profAndHigher => {
            // r reachable from sciences park at time t with accesslevel prof
            // note: do not need to check for lower levels b/c there are no lower levels
            reachableWithAccessLevel[Sciences_Park, r, t, Prof]
            and reachableWithAccessLevel[Sciences_Park, r, t, Security]
            and not reachableWithAccessLevel[Sciences_Park, r, t, Student]
            and not reachableWithAccessLevel[Sciences_Park, r, t, Public]
            and not reachableWithAccessLevel[Sciences_Park, r, t, TA]
        }

        r in EquivClasses.TAandHigher => {
            // r reachable from sciences park at time t with accesslevel TA
            // note: do not need to check for lower levels b/c there are no lower levels
            reachableWithAccessLevel[Sciences_Park, r, t, TA]
            and reachableWithAccessLevel[Sciences_Park, r, t, Prof]
            and reachableWithAccessLevel[Sciences_Park, r, t, Security]
            and not reachableWithAccessLevel[Sciences_Park, r, t, Student]
            and not reachableWithAccessLevel[Sciences_Park, r, t, Public]
            
        }
        
        r in EquivClasses.studentAndHigher => {
            // r reachable from sciences park at time t with accesslevel student
            // note: do not need to check for lower levels b/c there are no lower levels
            reachableWithAccessLevel[Sciences_Park, r, t, Student]
            and reachableWithAccessLevel[Sciences_Park, r, t, TA]
            and reachableWithAccessLevel[Sciences_Park, r, t, Prof]
            and reachableWithAccessLevel[Sciences_Park, r, t, Security]
            and not reachableWithAccessLevel[Sciences_Park, r, t, Public]
        }

        r in EquivClasses.publicAndHigher <=> {
            // r reachable from sciences park at time t with accesslevel public
            // note: do not need to check for lower levels b/c there are no lower levels
            reachableWithAccessLevel[Sciences_Park, r, t, Public]
            and reachableWithAccessLevel[Sciences_Park, r, t, Student]
            and reachableWithAccessLevel[Sciences_Park, r, t, TA]
            and reachableWithAccessLevel[Sciences_Park, r, t, Prof]
            and reachableWithAccessLevel[Sciences_Park, r, t, Security]
        }
    }
    //In each equivalence class, all rooms cannot be accessed by a lower level
}

// run {
//     traces[Sciences_Park, Lobby_F2, BusinessHours, Student]
// } for exactly 8 Door, 7 Room, 5 Int

run {
    validEquivClasses[BusinessHours]
} for exactly 8 Door, 7 Room, 5 Int