World Region System Module (WRSM) by itlticket
Ver. 0.0.2 (Cryptid)
Last update engine ver. v4.0.2.stable.official [7a0977ce2]

 - Table of Conents - 
I. Intro
II. How to use
III. What's going on in there?
IV. Troubleshooting

I. Intro

I started working on wrsm in late 2021 to address an issue I had with a certain jam game of mine. I
wanted to have a large, "open" structure for the world but did not have a simple way to avoid loading
the entire map scene at once when the Player entered the Overworld. This was not an issue in the
executable versions of the project, but caused noticeable slowdown/audio desync/other issues in the
HTML 5 export of the game, which constituted over 85% of the engagement that project received on 
itch.io. Looking back, it's the one thing I regret not having addressed in that jam experience.

At a high level, wrsm is intended to partition large 2D game spaces into smaller pieces to improve
performance in web-playable Godot projects, which consistently provide indie developers who publish 
to platforms like itch.io more engagement than projects that users must download and execute.

wrsm operates with 3 core units. These are:
	1. The RegionCell - The smallest unit. Assumed to be at least 1 in-game screen of playable space.
	These are the actual rooms or levels that your Player/enemies/items/etc. will be occupying.
	2. The WorldRegion - A collection of RegionCells that sit adjacent to each other in game space. 
	Assumed to be arranged in a grid. WorldRegions are *never actually loaded directly in your game
	at runtime*. Instead, you arrange your RegionCells in a RegionMap scene, which will write the
	RegionCell connections to a simple .json database organized by WorldRegion name. 
	3. The World - This contains Player node, the WorldCamera (which typically follows the Player
	node), and all loaded RegionCells from the WorldRegion the Player currently inhabits.

In short, The World is made up of x WorldRegions, which are themselves made up of y RegionCells, which
is where your Player will be running around and doing whatever it is they do.

wrsm can accomodate many different 2D game styles, but was intended for games that resemble top-down
Zelda style games and Metroidvanias where the Player transitions between bespoke "rooms" or "screens"
to navigate the game world. 

II. How to use

First, the WorldRegion.gd script must be added as an autoload for your project. It does some 
important stuff.

Secondly, you need to have defined your game's base viewport resolution. You likely already have, but
if not, do it now. Once you have defined this, remember that a Region Cell is intended to be 1 in-game 
"screen." Use this knowledge to set up your 1x1 Cell template accordingly. 

Things work best when the CollisionShape2D for the PlayerDetector Area2D scene is centered in your
RegionCell and its size is one half tile smaller than the boundaries of the room on each side. So,
if your 1x1_RegionCell is 256px by 144px (default setup), your PlayerDetector CollisionShape will be
240px by 128px.

After creating a new template, do yourself a favor and hide the Utils node. Everything will look so 
much nicer.

Once you have a template to start from, you can build rooms in you WorldRegion, build that Region's 
data, drop your player into a room, and start playing.

When creating an actual playable RegionCell for your project, follow this naming convention:
	RegionKey_RegionCellName

Where RegionKey is the same String specified in the RegionMap this Cell belongs to (a little redundant
I will think of a better way eventually).

III. What's going on in there?

Recall, wrsm treats your game's world like this:
	- The smallest playable space in the game is a single RegionCell, which range in size from the
	dimensions of your viewport at their smallest to an arbitrarily large size.
	- RegionCells form connections to each other in a space called WorldRegion. 
	- The World can contain a number of distinct WorldRegions. 

IV.
Just get good I guess

