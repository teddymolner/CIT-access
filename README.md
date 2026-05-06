# Introduction

Our goal for this project was to use Forge to provide a rigorous assessment of the security of the CIT. While the CIT was our medium, the predicates and structure of the code is general enough to work for any building, and we claim this is a useful tool for any buildings with complex swipe access patterns and multiple modes of transportation (i.e. stairs, elevator). 

To carry out our goals, we wanted the project to act as a tool so that for example a security analyst could carry out a workflow to assess the security of a building. Our final output manifested itself in allowing for the following workflow: 
1. Use validEquivClasses to see every room in the CIT split into equivalence classes depending on where an access level can reach from some starting location and time of day.
2. If this reveals information about access that we want to investigate more (e.g. a lower access level can reach some room that should be restricted), write a custom traces statement to show how an access level can get from one room to another through discrete steps (seen through our custom visualizer)
This allows informed decisions to be made about security of the whole system.

For our "three buckets", we stayed true to our core goals of being able to determine whether someone with swipe access X can go from room Y to room Z. We also implemented some of our target goals, which were closely related such as defining access at different times (business Hours, off hours on the weekday, and off hours on the weekend). Another target goal that we implemented was defining equivalence classes, which was also closely related to the core of our model. Some of our stretch goals we decided were not related and thus chose not to incorporate them into the model, such as faculty offices and shortest distance. However, one stretch goal that we did manage to implement was in finding out any security vulnerabilities. One such vulnerability is that our model showed that someone from the public starting on the third floor lobby can access almost the entire CIT during off hours. In real life, one can conceive of there being some event on the third floor where a member of the public is given access to, but then they could roam off an enter rooms where they probably should not be allowed during off hours.

# Design tradeoffs and Assumptions

Throughout this project, we had to make various choices and assumptions about our system to rigorously define sigs and generate a reasonable output. Below is a list of important design decisions that we made:
1. Every access level can go from a "restricted room" to an "unrestricted room". For example, when starting in the sciences park, access to the first floor lobby of the CIT is restricted as swipe access is required. Only certain levels of access can go through this door. For our assumption, we decided that going from the lobby to the sciences park outside is entirely unrestricted. In our view, this is reasonable as most doors that require a lock are only one-way, and you can always get to the first floor of an elevator from any floor.
2. We decided to think about movement through the CIT as a graph, where each room represents a node, and edges are represented by what we called "doors". While most of our doors were actually doors in real life, in order to simplify the model, we also represented elevators and stairs as doors between the lobbies of two floors.
3. We decided to model each access level (Public, Student, TA, Prof, and Security) as subsets of each other in order to simplify the model. This led to our predicate atLeast, which only checks if the access level of a person is at least the access level of a room in order to grant access. While this is not a perfect assumption as it is possible to conceive of some situation where, say, a TA could access a room that a Prof could not, this assumption is still well within reason. This assumption is also what let us define our equivalency classes, because in these we put a room in an equivalency class if it can be accessed by that access level and no level below it. Without our assumption, this logic would become significantly more complicated.
4. We were not able to map every single room and pathway in the CIT, as there are a significant number of rooms and entryways that we don't even know about (for example the basement). We did our best, using floorplans as a guide as well as our own understanding of swipe access in the building, but at the end of the day it is not a perfect model.

# How our model works

Our model works by using ideas about various predicates that we have talked about throughout the semester. The key access check between two rooms is our predicate canTraverse, which checks if there is a door such that a Person with a certain access level can move through between two rooms at a given time. Everything else in the model builds off of this, with cour step predicate defining movement from one room to another by checking canTraverse. We now use temporal forge to define a reachability predicate that checks whether, eventually, a person starting in one room will be located in another room. These predicates are the core of the model and allow us to create the standard "traces" predicate which shows the pathway of how a Person can get from one room to another at an access time.

However, the specific pathfinding is only one part of the model. The other part of the model we use to generate equivalency classes, allowing broad conclusions to be drawn about the security of the CIT. We needed to augment our predicates for this, because the first part relies on a single Person sig (which is great for path finding, but not so much for figuring out reachability between all of the rooms). Thus, for our equivalency class generation, we defined new sigs "canUseDoor", "edges", and "reachableWithAccessLevel". These are all very similar to the predicates discussed above, with the exception being that edges builds a relation mapping one room to another if someone could use a door between those two rooms. This allows efficient checking of reachability, so we use reachableWithAccessLevel extensively in validEquivClasses to generate our disjoint union satisfying the constraint mentioned above that a room is put in an equivalence class if cannot reach an access level below it. 



# How and why to use this model

There are two main uses in running our model:
1) To determine if, given some access time and access level, a person can get from room X to room Y
2) To partition every room in the CIT into access-level based equivalence classes based on some given starting room

The second use is the more confusing (but useful) one. We define 5 different access levels, in order of increasing permission: 
1. `Public` (anyone), 
2. `Student` (Brown ID card holders),
3. `TA` (CS dept. TAs),
4. `Prof` (CS dept. professors/administrative staff),
5. `Security` (university security).

Then, given a starting time T and room R, a room's assigned equivalence class (of which there are 5, each corresponding to one of the access levels) represent the *minimum* level of access needed to get to that room (no matter the path) at the given time, if you start in room R. It effectively tells us "if the person has at most these permissions and start here, where can they go?". The result is, intuitively, a partition of the room space.

## Proposed workflow
The use of this model to verify security of the CIT (or some other building) becomes useful when these two are used in conjunction. Our proposed workflow is:
1. Use validEquivClasses to see equivalence classes from a start room at varying hours.
2. If this reveals information about access that we want to investigate more, write a custom traces statement (1) to show how. In particular, use (1) can be used to get more detail about how a specific room may be accessed from some other specific room in a surprising way.
3. An access level can get from a room to another room through discrete steps.
4. This allows informed decisions about security to be made.



## Example usage
For reference, working example calls for each use case are found at the bottom of `cit_access.frg`.

### Searching for a path between two rooms
Pick some AccessLevel `A`, an AccessTime `T`, a start room `R0`, and a "goal" end room `R1`.
* The AccessLevel is one of `Public`, `Student`, `TA`, `Prof`, `Security`. 
* The AccessTime is one of `BusinessHours`, `OffHoursWeekday`, `OffHoursWeekend`.

Then, use the traces statement:
```
run {
    traces[R0, R1, T, A]
} for exactly 41 Door, 31 Room, 5 Int
```
A result of UNSAT indicates that the desired path does not exist. If a result is found, there is a JavaScript **visualizer** (contained in `vis.js`) provided to nicely visualize each step of the path, which you can enable by finding the trace, clicking on Script, then \<svg>, then Run.

#### More on the visualizer
Our visualizer was primarily created by ChatGPT. We prompted it by using a sample temporal visualizer, shared with us by our design check TA, and various non-temporal visualizers from the class textbook and labs. The main consideration was how to display the rooms -- did we want to create some sort of 3D map? Would a graph representation suffice? We ended up ordering rooms by floor level height (dynamically, by looking at the first number in a room's code), and then ordering them by code within each height level.

The other decision was to only display edges between nodes if those edges are used in the trace. If we showed all connections (doors/elevators/stairs) between rooms, the visualizer would quickly become difficult to make sense of. As such, only edges that are used at some point in the trace are shown, and the current edge (at that time step) is highlighted.

### Partitioning rooms into equivalence class levels
As described above, for some starting room, you can partition all rooms into five equivalence classes which represent the minimum level of access required to get there. 
Pick some starting room `R0` and some AccessTime `T`. Then use the traces statement:
```
run {
    validEquivClasses[R0, T]
} for exactly 41 Door, 31 Room, 5 Int
```

# What we got out of it

This project turned out to be a really enlightening modeling exercise as we learned a ton about working with temporal forge, defining custom visualizers, managing complexity and time constraints, as well as modeling a physical system. We are pleased to have chosen a physical system because working with real-life constraints and real-life data is a useful exercise and very different from a virtual project or abstract system such as what we worked with on our midterm. In addition, since this project is extensible to other buildings, we could make similar judgments about various other buildings on campus to help boost security. 

# Collaborators
The use of LLMs was very beneficial for this project, particularly for data entry, correctness of tests, and visualization:
*  By nature of the CIT, there are many rooms and doors to be entered. Fortunately, we developed a predictable syntax for entering rooms, and after creating a few example entries, we were able to simply write down the list of rooms in plain text and input them into ChatGPT (along with our data file) to format them correctly for the `buildMap` predicate. Of course, we verified the correctness of these through manual inspection and predictable trace runs afterwards.
* In creating tests, we used Claude to generate interesting circumstances that we should write tests to verify the correctness of. This helped us ensure our test suite was sufficiently comprehensive.
* Our visualizer, as explained above, was JavaScript based and (the only part of the project which was) created almost entirely by ChatGPT (exclusive of extensive prompting from us humans). See the "more on the visualizer" section for an explanation of our experience using AI to create the visualizer.

Other than ChatGPT/Claude, we had no other collaborators.