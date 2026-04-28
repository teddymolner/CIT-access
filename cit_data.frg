#lang forge/temporal

sig Floor {}
abstract sig Room { floor: one Floor }
abstract sig AccessLevel {}

one sig Public, Student, TA, Prof, Security extends AccessLevel {}

abstract sig AccessTime {}
one sig BusinessHours, OffHoursWeekday, OffHoursWeekend extends AccessTime {}

one sig EquivClasses {
    security: set Room,
    profAndHigher: set Room


}

// to -> from is always accessible by override (e.g. emergency exit)
sig Door { 
    from, to: one Room, 
   // minLevel: one AccessLevel, 
   
   // Maps AccessTime to minimum level that can access (since we are assuming that level and greater can access)
    accessible: func AccessTime -> AccessLevel
}

sig Transport extends Door { 
    kind: one TransportKind 
}

abstract sig TransportKind {} // stairs, elevator, exit

one sig Stairs, Elevator extends TransportKind {}

one sig Person { 
    level: one AccessLevel,
    var loc: one Room
}

// Assuming hallways are part of each respective lobby
one sig Sciences_Park, Lobby_F1, Lobby_F2, Lobby_F3, Lobby_F4, Lobby_F5 extends Room {} 

one sig Room101 extends Room {}

// To simplify, we're assuming it's always possible to go from higher to lower floors at any time

pred buildMap {
    // Door from Sciences Park to Lobby
    // Access rule:
        // Open during business hours to students and above
        // Always open to TAs and above
    some D: Door | {
        D.from = Sciences_Park
        D.to = Lobby_F1

        D.accessible[BusinessHours] = Student
        D.accessible[OffHoursWeekday] = TA
        D.accessible[OffHoursWeekend] = TA
    }


    // Door from Lobby to Room 101
    // Access rule: 
        // Open during business hours to students and above
        // Always open to TAs and above
    some D: Door | {
        D.from = Lobby_F1
        D.to = Room101

        D.accessible[BusinessHours] = Student
        D.accessible[OffHoursWeekday] = TA
        D.accessible[OffHoursWeekend] = TA
    }

    // *** ELEVATORS *** //
    
    // Elevator from Floor 1 Lobby to Floor 2 Lobby
    // Access rule:
        // Always open to everybody
    some T: Transport | {
        T.kind = Elevator
        T.from = Lobby_F1
        T.to = Lobby_F2
        
        T.accessible[BusinessHours] = Public
        T.accessible[OffHoursWeekday] = Public
        T.accessible[OffHoursWeekend] = Public
    }

    // Elevator from Floor 1 Lobby to Floor 3 Lobby
    // Access rule:
        // Open to everybody during business hours
        // Open to TAs and above during non business hours
    some T: Transport | {
        T.kind = Elevator
        T.from = Lobby_F1
        T.to = Lobby_F3
        
        T.accessible[BusinessHours] = Public
        T.accessible[OffHoursWeekday] = TA
        T.accessible[OffHoursWeekend] = TA
    }

    // Elevator from Floor 1 Lobby to Floor 4 Lobby
    // Access rule:
        // Open to everybody during business hours
        // Open to TAs and above during non business hours
    some T: Transport | {
        T.kind = Elevator
        T.from = Lobby_F1
        T.to = Lobby_F4
        
        T.accessible[BusinessHours] = Public
        T.accessible[OffHoursWeekday] = TA
        T.accessible[OffHoursWeekend] = TA
    }

    // Elevator from Floor 1 Lobby to Floor 5 Lobby
    // Access rule:
        // Open to everybody during business hours
        // Open to TAs and above during non business hours
    some T: Transport | {
        T.kind = Elevator
        T.from = Lobby_F1
        T.to = Lobby_F5
        
        T.accessible[BusinessHours] = Public
        T.accessible[OffHoursWeekday] = TA
        T.accessible[OffHoursWeekend] = TA
    }

    // *** STAIRS *** //

    // Stairs from Floor 1 Lobby to Floor 2 Lobby
    // Access rule:
        // Always open to everybody
    some T: Transport | {
        T.kind = Stairs
        T.from = Lobby_F1
        T.to = Lobby_F2
        
        T.accessible[BusinessHours] = Public
        T.accessible[OffHoursWeekday] = Public
        T.accessible[OffHoursWeekend] = Public
    }
    
    // Stairs from Floor 2 Lobby to Floor 3 Lobby
    // Access rule:
        // During business hours, open to public
        // Out of business hours, open to TAs and above
    some T: Transport | {
        T.kind = Stairs
        T.from = Lobby_F2
        T.to = Lobby_F3
        
        T.accessible[BusinessHours] = Public
        T.accessible[OffHoursWeekday] = TA
        T.accessible[OffHoursWeekend] = TA
    }
}
