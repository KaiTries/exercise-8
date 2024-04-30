// sensing agent


/* Initial beliefs and rules */


/* Initial goals */
!start. // the agent has the goal to start

/* 
 * Plan for reacting to the addition of the goal !start
 * Triggering event: addition of goal !start
 * Context: the agent believes that it can manage a group and a scheme in an organization
 * Body: greets the user
*/
@start_plan
+!start : true <-
	.print("Hello world").


+new_organization(OrgName) : true <- // the agent is informed about a new organization
	.print("New Organization called: ", OrgName);
	// join the workspace
	joinWorkspace(OrgName);
	lookupArtifact(OrgName,Id);
	focus(Id).

+group(GroupId, GroupType, ArtId) : true <-
	.print("New Group called: ", GroupId, " of type: ", GroupType, " in organization: ", ArtId);
	lookupArtifact(GroupType,Id);
	focus(Id).

+scheme(SchemeId, SchemeType, ArtId) : true <-
	.print("New Scheme called: ", SchemeId, " of type: ", SchemeType, " in organization: ", ArtId);
	lookupArtifact(SchemeType,Id);
	focus(Id).

// when joining an organization we are informed about the different goal states
// we check if for the given goalState we have the Plan that is required for it
+goalState(Scheme, Goal, Person1, Person2, waiting) : true <-
	.relevant_plans({+!Goal}, LP);
	!find_role_for_goal(Goal, LP).

// if we have a plan that is required for the goal, then we find the corresponding Role for the plan
// we do this by getting the mission corresponding to the goal and the Role for the mission
+!find_role_for_goal(Goal, LP) : LP \== [] & mission_goal(MT,Goal) & role_mission(Role,S,MT) <-
	.print("Adopting Role: ", Role);
	adoptRole(Role).


+!find_role_for_goal(Goal, LP) : LP == [] <- 
	.print("No plans for this role").
/* 
 * Plan for reacting to the addition of the goal !read_temperature
 * Triggering event: addition of goal !read_temperature
 * Context: true (the plan is always applicable)
 * Body: reads the temperature using a weather station artifact and broadcasts the reading
*/
@read_temperature_plan
+!read_temperature : true <-
	.print("I will read the temperature");
	makeArtifact("weatherStation", "tools.WeatherStation", [], WeatherStationId); // creates a weather station artifact
	focus(WeatherStationId); // focuses on the weather station artifact
	readCurrentTemperature(47.42, 9.37, Celcius); // reads the current temperature using the artifact
	.print("Temperature Reading (Celcius): ", Celcius);
	.broadcast(tell, temperature(Celcius)). // broadcasts the temperature reading

/* Import behavior of agents that work in CArtAgO environments */
{ include("$jacamoJar/templates/common-cartago.asl") }

/* Import behavior of agents that work in MOISE organizations */
{ include("$jacamoJar/templates/common-moise.asl") }

/* Import behavior of agents that reason on MOISE organizations */
{ include("$moiseJar/asl/org-rules.asl") }

/* Import behavior of agents that react to organizational events
(if observing, i.e. being focused on the appropriate organization artifacts) */
{ include("inc/skills.asl") }