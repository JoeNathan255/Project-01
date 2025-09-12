/*
    Project 01
    
    Requirements (for 15 base points)
    - Create an interactive fiction story with at least 8 knots 
    - Create at least one major choice that the player can make
    - Reflect that choice back to the player
    - Include at least one loop
    
    To get a full 20 points, expand upon the game in the following ways
    [+2] Include more than eight passages
    [+1] Allow the player to pick up items and change the state of the game if certain items are in the inventory. Acknowledge if a player does or does not have a certain item
    [+1] Give the player statistics, and allow them to upgrade once or twice. Gate certain options based on statistics (high or low. Maybe a weak person can only do things a strong person can't, and vice versa)
    [+1] Keep track of visited passages and only display the description when visiting for the first time (or requested)
    
    Make sure to list the items you changed for points in the Readme.md. I cannot guess your intentions!

13 knots total
 - 7 

*/

VAR light = false
VAR throw_msg = ""
VAR result = ""
VAR time = 0
LIST status_updates = five = 5, ten = 10, fifteen = 15, twenty = 20, twenty_five = 25, twenty_eight = 28, twenty_nine, thirty

-> entrance

/* These first two functions are just flavor text, for fun */
== enter_cave ==
    <> {~The sky is cut off from your view.|⠀} /* I somewhat embarrasingly couldn't figure out Ink's whitespace escape character, so I'm using unicode U+2800 */
    ->->

== exit_cave ==
    <> {~The sky opens up far above you.|⠀}
    ->->

/* This tunneling knot was added for exercise 01d; it's just a way of making the function-based time implementation feel more in line with the style of this game & its codebase (and avoid repetitive code) */
== advance_time ==
    ~ time ++
    {time:
            - 5:    <> Your leg aches vaguely.
            - 10:   <> You feel increasingly tired.
            - 15:   <> Your stomach begins to growl insistently.
            - 20:   <> Your vision goes dark at the edges. You'd better get out of here, soon.
            - 24:   <> Fatigue sets in sharply.
            - 25:   <> You don't think you'll be able to go on much longer.
            - 28:   <> Your vision is almost too blurry to see.
            - 29:   <> Your legs begin to give out.
            - 30:   <> You try still to ignore the pain, but now it grows too much. Your strength expended, you slump over. See you next life. -> END
        }
    ->->
    = outside
        /* I really don't like this line, but best I can tell, you just can't up get Ink lists to play nice like arrays and just check if a numerical value is present (e.g. "if 4 in list"). I left the list from my attempt at the top, and I tried status_updates !? ststus_updates(time), which I thought should have at least done something, but I could never get lists to return anything remotely like I expected. Tried messing around with LIST_VALUE() as well, still to no avail. So, this line exists. Sorry! */
        {(time != 4) and (time != 9) and (time != 14) and (time != 19) and (time != 23) and (time != 24) and (time != 27) and (time != 28) and (time != 29):
            {
                - time % 12 <= 3:    <> {~The sun lies directly overhead.|⠀} // 4 units long
                - time % 12 <= 5:    <> {~The dim glow of sunset illuminates the ravine.|⠀} // 2 units long
                - time % 12 <= 9:    <> {~Only the moon serves to illuminate your surroundings.|⠀} // 4 units long
                - time % 12 <= 12:   <> {~The sunrise shines on the canyon's western wall.|⠀} // 2 units long
                - else: you broke something :(
            }
        }
        -> advance_time ->
        ->->


== torch_use ==
    {river_tunnel.knife_get:
        You manage to light the torch with your pocketknife as a fire striker.
        ~ light = true
    - else:
        You try to light your torch, but don't have a spark.
    }
    ->->

== entrance ==
    {You lay at the bottom of a chasm|The chasm stretches above you}. {not light:The dim lighting reveals sheer walls continuing|Sheer walls continue} to the north and south. 
    + [Walk north] You walk north.
        -> advance_time.outside -> north_entrance
    + [Walk south] You walk south.
        -> advance_time.outside -> south_entrance

== south_entrance ==
    /* I decided to use if/else rather than stitches for larger light checks, just to make tunneling from == torch_use == easier on myself */
    {light:
        The ground here is uneven. To the north, it opens into a ravine. To the south, it descends into a jagged passageway.
        + [Walk north] You walk north.
            -> advance_time.outside -> entrance
        + [Walk south] You walk south.
            -> enter_cave -> advance_time -> south_passage
    - else:
        The ground here is uneven, and not much light filters down from above. You don't think you can continue on without more light.
        + [Walk north] You walk north.
            -> advance_time.outside -> entrance
        + {north_entrance.torch_get and not light} [Light torch]
            -> torch_use -> south_entrance
    }

== north_entrance ==
    {not light:Some light filters down from above.} You hear running water to the north, and the ground slopes downward to the south. {not torch_get:A torch lies on the floor.}
    + [Walk north] You walk north.
        -> advance_time.outside -> north_river
    + [Walk south] You walk south.
        -> advance_time.outside -> entrance
    * [Pick up torch]
        -> torch_get

    = torch_get
        You pick up the torch. It looks like it'll burn, if you can find a way to light it.
        -> north_entrance

== north_river ==
    The ravine here narrows to the bottom of a waterfall. The current channels into a small tunnel to the southwest. {not light:{not east_alcove:You can't see much in the low light, but the eastern wall seems more shadowed than the rest|The eastern wall opens up into darkness}|An alcove opens to the east}.
        + [Enter the tunnel] You crawl southwest through knee-deep water{light:, careful not to extinguish your torch}.
            -> enter_cave -> advance_time -> river_tunnel
        + [Walk south] You walk south.
            -> advance_time.outside -> north_entrance
        + {light} [Walk east] You walk east.
            -> enter_cave -> advance_time -> east_alcove
        + {not light} [{Investigate the wall|Walk east}] {You take a closer look at the eastern wall|You walk east}.
            -> advance_time -> east_alcove

== river_tunnel ==
    {Eventually, the tunnel opens up into|You stand in} a small cavern. {not light:You can't see much{not knife_get:, but something glimmers in the darkness| in the darkness}|The walls are worn smooth by the underground river}.
    + [Leave the cave] You crawl northeast against the current.
        -> exit_cave -> advance_time.outside -> north_river
    * [Investigate] You take a closer look.
        -> knife_get
    * {north_entrance.torch_get and knife_get and not light} [Light torch] You fail to light your torch in the damp cave.
        -> river_tunnel
        
    = knife_get
        The item reveals itself to be an old pocketknife nestled amongst the stones. The barely-legible handle tells you it's high-quality steel, though long rusted over. You pocket the knife.
        -> river_tunnel

== east_alcove ==
    {not light:{!In fact, the wall falls back into a cave; you have no idea how deep. }Very little light makes it around the corner. You stand in near-pitch darkness|You stand in a small alcove in the cliff face. Directly in front of you lies a skeleton dressed in rags{!| (poor guy)}}.
    + [Walk west] You walk west{not light:, out of the darkness}.
        -> exit_cave -> advance_time.outside -> north_river
    + {north_entrance.torch_get and not light} [Light torch]
            -> torch_use -> east_alcove
    * {light} [Investigate]
        -> rope_get

    = rope_get
        This has been here for a while. In what remains of a backpack, you find only a length of rope. You pick it up.
        -> east_alcove

== south_passage ==
    {rope_throw.throw_count < 3:You find yourself at the bottom of a steep descent to the north. To the southeast lies a{not climb: steep|n} upward incline in the cave{climb:, too steep to climb}.|You stand before a wall to the southeast, your rope hanging down at arm's length. The ravine lies to the north.}
    + [Walk north] You climb out of the cave.
        -> exit_cave -> advance_time.outside -> south_entrance
    * {rope_throw.throw_count < 3} [Climb the wall] You attempt to climb to the southeast.
        -> climb
    + {east_alcove.rope_get and rope_throw.throw_count < 3} [Throw the rope] You see by the light of your torch an outcropping near the top of the slope.
        -> rope_throw
    + {rope_throw.throw_count > 3} [Climb the rope] You climb up to the southeast.
        -> advance_time -> escape

    = climb
        It proves far too steep, and you fall back down to the bottom, nearly losing your torch in the process.
        -> advance_time -> south_passage

/* I can't figure out any better way to deal with this situation, as the default for alternatives (sequences) increment every time you see them, rather than every time they're selected. Since I wanted to play with the prompt message, I resorted to... this :/  */
== rope_throw ==
    {throw_count > 3:
        -> advance_time -> south_passage
    }
    { throw_count:
        - 0:    You fashion your rope into a makeshift lasso, and prepare to throw the end at the rock.
        - 1:    You gather your rope and prepare to try again.
        - 2:    You pick up your rope.
        - 3:    You pick up your rope. Again.
        - else: you broke something :(
    }
    { throw_count:
        - 0:    ~ throw_msg = "Make the shot"
        - 1:    ~ throw_msg = "Throw it again"
        - 2:    ~ throw_msg = "Throw it again"
        - 3:    ~ throw_msg = "This is harder than it looks"
        - else: ~ throw_msg = "you broke something :("
    }
    { throw_count:
        - 0:    ~ result = "You throw your rock at the outcropping. It misses by a mile and slides back down to your feet."
        - 1:    ~ result = "Not one to give up, you throw it again. It almost looks like you've got it, until the rope lands dutifully back at your feet."
        - 2:    ~ result = "You begin to lose hope as you fail again, the rope piling up on the ground."
        - 3:    ~ result = "You throw the rope halfheartedly. It lands exactly around the outcropping and holds fast."
        - else: ~ result = "you broke something :("
    }
    + [{throw_msg}] {result}
        -> throw_count
    + [Return] You think better of it for the time being.
        -> south_passage
    
    = throw_count
        -> advance_time -> rope_throw

== escape ==
    The cave here slopes up gently away from the ravine to the east. You see some light at the end of the tunnel.
    + [Climb down] You climb down to the northwest.
        -> advance_time -> south_passage
    + [Walk east] You follow the passage to the east.
        -> escape_2
    
    = escape_2
    The cave curves upward further here. The cave is illuminated from above and now in front of you. Walking forward, you hear birdsong as the horizon comes into view.
        -> END