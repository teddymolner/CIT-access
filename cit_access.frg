#lang forge
open "cit_data.frg"

sig Floor {}
abstract sig Room { floor: one Floor }
abstract sig AccessLevel {}

one sig Public, Student, TA, Prof, Security extends AccessLevel {}

abstract sig AccessTime {}
one sig BusinessHours, OffHoursWeekday, OffHoursWeekend extends AccessTime {}

one sig EquivClasses {
    security: set Room,
    profAndHigher: set Room,


}

sig Door { 
    from, to: one Room, 
    minLevel: one AccessLevel,
    accessible: AccessTime -> set AccessLevel
}

sig Transport extends Door { 
    kind: one TransportKind 
}

sig TransportKind {} // stairs, elevator, exit

one sig Person { 
    level: one AccessLevel
    loc: one Room
}

pred staysInRoomForever[r: Room] {
    always(Person.loc == r)
}
pred canTraverse[d: Door, t: AccessTime] {

}

pred step[r: Room, r1: Room, t: AccessTime] {

}

pred reachable[start: Room, end: Room, t: AccessTime] {

}