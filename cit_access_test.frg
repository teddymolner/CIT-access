#lang forge/temporal
open "cit_data.frg"
open "cit_access.frg"

-- ============================================================
-- staysInRoomForever
-- ============================================================
test suite for staysInRoomForever {
    -- staysInRoomForever holds for end room in a traces scenario
    staysForeverImpliesNoFutureChange: assert {
        buildMap => (all r: Room | staysInRoomForever[r] => always(Person.loc = r))
    } is sat
}

-- ============================================================
-- atLeast
-- ============================================================
test suite for atLeast {
    -- Security satisfies all minimums
    publicAllowsAll: assert {
        buildMap => (all l: AccessLevel | atLeast[l, Public])
    } is sat

    -- Security is satisfied only by Security itself (not Public, Student, TA, Prof)
    securityAllowsOnlySecurity: assert {
        buildMap => (not atLeast[Public, Security]
        and not atLeast[Student, Security]
        and not atLeast[TA, Security]
        and not atLeast[Prof, Security]
        and atLeast[Security, Security])
    } is sat

    -- atLeast is NOT symmetric: atLeast[Student, TA] should be false
    atLeastNotSymmetric: assert {
        buildMap => (atLeast[TA, Student] and not atLeast[Student, TA])
    } is sat

}

-- ============================================================
-- canTraverse
-- ============================================================
test suite for canTraverse {
    -- If person is at door.to, traversal is always allowed regardless of access
    freeFromTraversal: assert {
        buildMap
        some d: Door, t: AccessTime | {
            Person.loc = d.to
            canTraverse[d, t]
        }
    } is sat for exactly 39 Door, 31 Room, 5 Int

    -- canTraverse is not trivially always true
    traversalAlwaysTrue: assert {
        buildMap
        all d: Door, t: AccessTime | canTraverse[d, t]
    } is unsat for exactly 39 Door, 31 Room, 5 Int

    -- A Security-level person can traverse any door at any time when at door.from
    securityCanTraverseAll: assert {
        buildMap
        some d: Door, t: AccessTime | {
            Person.level = Security
            Person.loc = d.from
            canTraverse[d, t]
        }
    } is sat for exactly 39 Door, 31 Room, 5 Int
}

-- ============================================================
-- step
-- ============================================================
test suite for step {

    -- step requires a valid door between the two rooms
    stepRequiresDoor: assert {
        buildMap
        some r, r1: Room, t: AccessTime | step[r, r1, t]
        =>
        (some d: Door | (d.from = Person.loc and d.to != Person.loc))
    } is sat for exactly 39 Door, 31 Room, 5 Int

    -- Person cannot step to a room with no door connecting them
    stepImpossibleWithNoDoor: assert {
        buildMap 
        some r, r1: Room, t: AccessTime | {
            no d: Door | d.from = r and d.to = r1
            step[r, r1, t]
        }
    } is unsat for exactly 39 Door, 31 Room, 5 Int

    -- After step, person's location is the destination room
    stepChangesLocation: assert {
        buildMap
        some r, r1: Room, t: AccessTime | {
            step[r, r1, t]
            Person.loc' = r1
        }
    } is sat for exactly 39 Door, 31 Room, 5 Int

    -- A student can step through a Student-access door during business hours
    studentStepDuringBusinessHours: assert {
        buildMap
        some d: Door | {
            d.accessible[BusinessHours] = Student
            Person.level = Student
            Person.loc = d.from
            step[d.from, d.to, BusinessHours]
        }
    } is sat for exactly 39 Door, 31 Room, 5 Int

    -- A Public-level person cannot step through a Student door during business hours
    publicCannotStepStudentDoor: assert {
        buildMap
        some d: Door | {
            d.accessible[BusinessHours] = Student
            Person.level = Public
            Person.loc = d.from
            step[d.from, d.to, BusinessHours]
        }
    } is unsat for exactly 39 Door, 31 Room, 5 Int
}

-- ============================================================
-- reachable
-- ============================================================
test suite for reachable {

    -- If start equals end, reachable is trivially true since person already has the right loc
    reachableSameRoom: assert {
        some r: Room | {
            Person.loc = r
            reachable[r, r, BusinessHours]
        }
    } is sat

    -- reachable requires Person.loc = start
    reachableRequiresStart: assert {
        some r, r1: Room | {
            Person.loc != r
            reachable[r, r1, BusinessHours]
        }
    } is unsat

    -- If a valid path exists across doors, reachable should hold
    reachableAcrossSingleDoor: assert {
        some d: Door, t: AccessTime | {
            Person.loc = d.from
            Person.level = Security
            reachable[d.from, d.to, t]
        }
    } is sat
}

-- ============================================================
-- traces
-- ============================================================
test suite for traces {

    -- A Public person can only reach rooms accessible at public level during business hours
    publicCannotReachSecurityRoom: assert {
        some r: Room | {
            not traces[Sciences_Park, r, BusinessHours, Public]
        }
    } is sat for exactly 39 Door, 31 Room, 5 Int

    -- traces establishes buildMap and access level constraints
    tracesSetsBuildMap: assert {
        traces[Sciences_Park, Lobby_F1, BusinessHours, Student]
        =>
        buildMap
    } is sat for exactly 39 Door, 31 Room, 5 Int

    -- Person stays in end room forever (staysInRoomForever) is an allowable trajectory
    tracesCanTerminate: assert {
        some r: Room | {
            traces[Sciences_Park, r, BusinessHours, Security]
            staysInRoomForever[r]
        }
    } is sat for exactly 39 Door, 31 Room, 5 Int

    -- A Student cannot trace to a room requiring TA access during off-hours
    studentCannotReachTARoomOffHours: assert {
        some r: Room | {
            not traces[Sciences_Park, r, OffHoursWeekday, Student]
        }
    } is sat for exactly 39 Door, 31 Room, 5 Int
}

-- ============================================================
-- canUseDoor
-- ============================================================
test suite for canUseDoor {

    -- Security can use any door at any time
    securityUsesAnyDoor: assert {
        buildMap
        all d: Door, t: AccessTime | canUseDoor[d, t, Security]
    } is sat for exactly 39 Door, 31 Room, 5 Int

    -- Public cannot use a Student-minimum door
    publicCannotUseStudentDoor: assert {
        buildMap
        some d: Door, t: AccessTime | {
            d.accessible[t] = Student
            not canUseDoor[d, t, Public]
        }
    } is sat for exactly 39 Door, 31 Room, 5 Int

    -- TA can use a TA-minimum door
    taCanUseTADoor: assert {
        buildMap
        some d: Door, t: AccessTime | {
            d.accessible[t] = TA
            canUseDoor[d, t, TA]
        }
    } is sat for exactly 39 Door, 31 Room, 5 Int
}

-- ============================================================
-- edges fun
-- ============================================================
test suite for edges {

    -- If a door exists from r1 to r2, r1->r2 is in edges for a high enough level
    edgesIncludesForwardDirection: assert {
        buildMap
        some d: Door, t: AccessTime | {
            d.from -> d.to in edges[t, Security]
        }
    } is sat for exactly 39 Door, 31 Room, 5 Int

    -- Reverse direction (d.to -> d.from) is always in edges regardless of level
    edgesAlwaysIncludesReverseDirection: assert {
        buildMap
        some d: Door, t: AccessTime | {
            d.to -> d.from in edges[t, Public]
        }
    } is sat for exactly 39 Door, 31 Room, 5 Int

    -- A Public person cannot traverse a door requiring Student via forward direction
    edgesExcludesInsufficientLevel: assert {
        buildMap
        some d: Door, t: AccessTime | {
            d.accessible[t] = Student
            d.from -> d.to not in edges[t, Public]
        }
    } is sat for exactly 39 Door, 31 Room, 5 Int
}
-- ============================================================
-- reachableWithAccessLevel
-- ============================================================
test suite for reachableWithAccessLevel {

    -- Security can reach all rooms reachable by Prof (superset)
    securityReachesSupersetOfProf: assert {
        buildMap
        all r: Room, t: AccessTime | {
            reachableWithAccessLevel[Sciences_Park, r, t, Prof]
            => reachableWithAccessLevel[Sciences_Park, r, t, Security]
        }
    } is sat for exactly 39 Door, 31 Room, 5 Int

    -- Public can reach all rooms reachable by... Public only (subset check)
    publicSubsetOfStudent: assert {
        buildMap
        all r: Room, t: AccessTime | {
            reachableWithAccessLevel[Sciences_Park, r, t, Student]
            => reachableWithAccessLevel[Sciences_Park, r, t, TA]
        }
    } is sat for exactly 39 Door, 31 Room, 5 Int

    -- Sciences_Park is always reachable from itself at any level (reflexive)
    selfReachable: assert {
        buildMap
        all t: AccessTime, l: AccessLevel | {
            reachableWithAccessLevel[Sciences_Park, Sciences_Park, t, l]
        }
    } is sat for exactly 39 Door, 31 Room, 5 Int
}
