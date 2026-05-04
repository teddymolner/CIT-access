#lang forge/temporal
open "cit_access.frg"

test suite for staysInRoomForever {

}

test suite for atLeast {
    example simpleContainment is some l, m : AccessLevel |  { atLeast[l, m] } for {

    }

    example sameLevel is some l, m : AccessLevel | { atLeast[l, m] } for {

    }

    example insufficientLevel is all l, m : AccessLevel | { not atLeast[l, m] } for {

    }

    publicAllowsAll: assert {

    } is sat

    securityAllowsOnlySecurity: assert {

    } is sat
}

test suite for canTraverse {
    example simpleTraversal is some d: Door, t: AccessTime | { canTraverse[d, t] } for {

    }

    example simpleNonTraversal is all d: Door, t: AccessTime | { not canTraverse[d, t] } for {

    }

    freeFromTraversal: assert {

    } is sat

    traversalAlwaysTrue: assert {

    } is unsat

    businessHoursSameAccess: assert {
        // all rooms should not have the same value for canTraverse at all times
    } is unsat
}

test suite for step {

    sameRoomTrue: assert {
        // can always step between the same room
    } is sat

}

test suite for reachable {

}

test suite for traces {

}