#lang forge/temporal

sig Floor {}
abstract sig Room { floor: one Floor }
abstract sig AccessLevel {}

one sig Public, Student, TA, Prof, Security extends AccessLevel {}

abstract sig AccessTime {}
one sig BusinessHours, OffHoursWeekday, OffHoursWeekend extends AccessTime {}

one sig EquivClasses {
    security: set Room,
    profAndHigher: set Room,
    TAandHigher: set Room,
    studentAndHigher: set Room,
    publicAndHigher: set Room
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


one sig Sciences_Park, Lobby_F1, Lobby_F2, Lobby_F3, Lobby_F4, Lobby_F5 extends Room {} 

one sig Room101, Room102, Room143, Room165, Room167,
        Room201, Room203, Room205, Room209, Room210, Room219, Room227, Room241, Room271,
        Room316, Room348, Room367, Room368,
        Room410, Room477,
        Room506, Room508, Room510, Room512 extends Room {}

// Specific named doors
one sig D_SciencesPark_LobbyF1 extends Door {}
one sig D_LobbyF1_Room101, D_LobbyF1_Room102, D_LobbyF1_Room143, D_LobbyF1_Room165, D_LobbyF1_Room167 extends Door {}
one sig D_LobbyF2_Room201, D_LobbyF2_Room203, D_LobbyF2_Room205, D_LobbyF2_Room209, D_LobbyF2_Room210, D_LobbyF2_Room219, D_LobbyF2_Room227, D_LobbyF2_Room241, D_LobbyF2_Room271 extends Door {}
one sig D_LobbyF3_Room316, D_LobbyF3_Room348, D_LobbyF3_Room367, D_LobbyF3_Room368 extends Door {}
one sig D_LobbyF4_Room410, D_LobbyF4_Room477 extends Door {}
one sig D_LobbyF5_Room506, D_LobbyF5_Room508, D_LobbyF5_Room510, D_LobbyF5_Room512 extends Door {}

one sig E_LobbyF1_LobbyF2, E_LobbyF1_LobbyF3, E_LobbyF1_LobbyF4, E_LobbyF1_LobbyF5 extends Transport {}
one sig E_LobbyF2_LobbyF3, E_LobbyF2_LobbyF4, E_LobbyF2_LobbyF5 extends Transport {}
one sig E_LobbyF3_LobbyF4, E_LobbyF3_LobbyF5 extends Transport {}
one sig E_LobbyF4_LobbyF5 extends Transport {}

one sig S_LobbyF1_LobbyF2, S_LobbyF2_LobbyF3, S_LobbyF3_LobbyF4, S_LobbyF4_LobbyF5 extends Transport {}

pred publicAlways[d: Door] {
    d.accessible[BusinessHours] = Public
    d.accessible[OffHoursWeekday] = Public
    d.accessible[OffHoursWeekend] = Public
}

pred swipeAccess[d: Door] {
    d.accessible[BusinessHours] = Public
    d.accessible[OffHoursWeekday] = TA
    d.accessible[OffHoursWeekend] = TA
}

pred buildMap {
    // Door from Sciences Park to Lobby
    D_SciencesPark_LobbyF1.from = Sciences_Park
    D_SciencesPark_LobbyF1.to = Lobby_F1
    D_SciencesPark_LobbyF1.accessible[BusinessHours] = Student
    D_SciencesPark_LobbyF1.accessible[OffHoursWeekday] = TA
    D_SciencesPark_LobbyF1.accessible[OffHoursWeekend] = TA

    // Floor 1 rooms
    D_LobbyF1_Room101.from = Lobby_F1
    D_LobbyF1_Room101.to = Room101
    publicAlways[D_LobbyF1_Room101]

    D_LobbyF1_Room102.from = Lobby_F1
    D_LobbyF1_Room102.to = Room102
    publicAlways[D_LobbyF1_Room102]

    D_LobbyF1_Room143.from = Lobby_F1
    D_LobbyF1_Room143.to = Room143
    publicAlways[D_LobbyF1_Room143]

    D_LobbyF1_Room165.from = Lobby_F1
    D_LobbyF1_Room165.to = Room165
    publicAlways[D_LobbyF1_Room165]

    D_LobbyF1_Room167.from = Lobby_F1
    D_LobbyF1_Room167.to = Room167
    publicAlways[D_LobbyF1_Room167]

    // Floor 2 rooms
    D_LobbyF2_Room201.from = Lobby_F2
    D_LobbyF2_Room201.to = Room201
    publicAlways[D_LobbyF2_Room201]

    D_LobbyF2_Room203.from = Lobby_F2
    D_LobbyF2_Room203.to = Room203
    publicAlways[D_LobbyF2_Room203]

    D_LobbyF2_Room205.from = Lobby_F2
    D_LobbyF2_Room205.to = Room205
    publicAlways[D_LobbyF2_Room205]

    D_LobbyF2_Room209.from = Lobby_F2
    D_LobbyF2_Room209.to = Room209
    publicAlways[D_LobbyF2_Room209]

    D_LobbyF2_Room210.from = Lobby_F2
    D_LobbyF2_Room210.to = Room210
    publicAlways[D_LobbyF2_Room210]

    D_LobbyF2_Room219.from = Lobby_F2
    D_LobbyF2_Room219.to = Room219
    publicAlways[D_LobbyF2_Room219]

    D_LobbyF2_Room227.from = Lobby_F2
    D_LobbyF2_Room227.to = Room227
    publicAlways[D_LobbyF2_Room227]

    D_LobbyF2_Room241.from = Lobby_F2
    D_LobbyF2_Room241.to = Room241
    publicAlways[D_LobbyF2_Room241]

    D_LobbyF2_Room271.from = Lobby_F2
    D_LobbyF2_Room271.to = Room271
    publicAlways[D_LobbyF2_Room271]

    // Floor 3 rooms
    D_LobbyF3_Room316.from = Lobby_F3
    D_LobbyF3_Room316.to = Room316
    publicAlways[D_LobbyF3_Room316]

    D_LobbyF3_Room348.from = Lobby_F3
    D_LobbyF3_Room348.to = Room348
    publicAlways[D_LobbyF3_Room348]

    D_LobbyF3_Room367.from = Lobby_F3
    D_LobbyF3_Room367.to = Room367
    publicAlways[D_LobbyF3_Room367]

    D_LobbyF3_Room368.from = Lobby_F3
    D_LobbyF3_Room368.to = Room368
    publicAlways[D_LobbyF3_Room368]

    // Floor 4 rooms
    D_LobbyF4_Room410.from = Lobby_F4
    D_LobbyF4_Room410.to = Room410
    publicAlways[D_LobbyF4_Room410]

    D_LobbyF4_Room477.from = Lobby_F4
    D_LobbyF4_Room477.to = Room477
    publicAlways[D_LobbyF4_Room477]

    // Floor 5 rooms
    D_LobbyF5_Room506.from = Lobby_F5
    D_LobbyF5_Room506.to = Room506
    publicAlways[D_LobbyF5_Room506]

    D_LobbyF5_Room508.from = Lobby_F5
    D_LobbyF5_Room508.to = Room508
    publicAlways[D_LobbyF5_Room508]

    D_LobbyF5_Room510.from = Lobby_F5
    D_LobbyF5_Room510.to = Room510
    publicAlways[D_LobbyF5_Room510]

    D_LobbyF5_Room512.from = Lobby_F5
    D_LobbyF5_Room512.to = Room512
    publicAlways[D_LobbyF5_Room512]

        // *** ELEVATORS *** //

    E_LobbyF1_LobbyF2.kind = Elevator
    E_LobbyF1_LobbyF2.from = Lobby_F1
    E_LobbyF1_LobbyF2.to = Lobby_F2
    publicAlways[E_LobbyF1_LobbyF2]

    E_LobbyF1_LobbyF3.kind = Elevator
    E_LobbyF1_LobbyF3.from = Lobby_F1
    E_LobbyF1_LobbyF3.to = Lobby_F3
    swipeAccess[E_LobbyF1_LobbyF3]

    E_LobbyF1_LobbyF4.kind = Elevator
    E_LobbyF1_LobbyF4.from = Lobby_F1
    E_LobbyF1_LobbyF4.to = Lobby_F4
    swipeAccess[E_LobbyF1_LobbyF4]

    E_LobbyF1_LobbyF5.kind = Elevator
    E_LobbyF1_LobbyF5.from = Lobby_F1
    E_LobbyF1_LobbyF5.to = Lobby_F5
    swipeAccess[E_LobbyF1_LobbyF5]

    E_LobbyF2_LobbyF3.kind = Elevator
    E_LobbyF2_LobbyF3.from = Lobby_F2
    E_LobbyF2_LobbyF3.to = Lobby_F3
    swipeAccess[E_LobbyF2_LobbyF3]

    E_LobbyF2_LobbyF4.kind = Elevator
    E_LobbyF2_LobbyF4.from = Lobby_F2
    E_LobbyF2_LobbyF4.to = Lobby_F4
    swipeAccess[E_LobbyF2_LobbyF4]

    E_LobbyF2_LobbyF5.kind = Elevator
    E_LobbyF2_LobbyF5.from = Lobby_F2
    E_LobbyF2_LobbyF5.to = Lobby_F5
    swipeAccess[E_LobbyF2_LobbyF5]

    E_LobbyF3_LobbyF4.kind = Elevator
    E_LobbyF3_LobbyF4.from = Lobby_F3
    E_LobbyF3_LobbyF4.to = Lobby_F4
    swipeAccess[E_LobbyF3_LobbyF4]

    E_LobbyF3_LobbyF5.kind = Elevator
    E_LobbyF3_LobbyF5.from = Lobby_F3
    E_LobbyF3_LobbyF5.to = Lobby_F5
    swipeAccess[E_LobbyF3_LobbyF5]

    E_LobbyF4_LobbyF5.kind = Elevator
    E_LobbyF4_LobbyF5.from = Lobby_F4
    E_LobbyF4_LobbyF5.to = Lobby_F5
    swipeAccess[E_LobbyF4_LobbyF5]

    // *** STAIRS *** //

    S_LobbyF1_LobbyF2.kind = Stairs
    S_LobbyF1_LobbyF2.from = Lobby_F1
    S_LobbyF1_LobbyF2.to = Lobby_F2
    swipeAccess[S_LobbyF1_LobbyF2]

    S_LobbyF2_LobbyF3.kind = Stairs
    S_LobbyF2_LobbyF3.from = Lobby_F2
    S_LobbyF2_LobbyF3.to = Lobby_F3
    swipeAccess[S_LobbyF2_LobbyF3]

    S_LobbyF3_LobbyF4.kind = Stairs
    S_LobbyF3_LobbyF4.from = Lobby_F3
    S_LobbyF3_LobbyF4.to = Lobby_F4
    swipeAccess[S_LobbyF3_LobbyF4]

    S_LobbyF4_LobbyF5.kind = Stairs
    S_LobbyF4_LobbyF5.from = Lobby_F4
    S_LobbyF4_LobbyF5.to = Lobby_F5
    swipeAccess[S_LobbyF4_LobbyF5]
}