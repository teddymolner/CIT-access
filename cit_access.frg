#lang forge
open "cit_data.frg"

option run_sterling "vis.js"

pred staysInRoomForever[r: Room] {
    always(Person.loc = r)
}
pred canTraverse[d: Door, t: AccessTime] {

}

pred step[r: Room, r1: Room, t: AccessTime] {

}

pred reachable[start: Room, end: Room, t: AccessTime] {

}

run {
    buildMap
} for exactly 7 Door, 6 Room