World Region System Module (WRSM) 
Documentation
Version: 0.0.1
Last update: Godot v. 4 beta 1

 - Table of Conents - 
I. Intro
II. How to use
III. What's going on down there?
IV. Troubleshooting

I. Intro

I started working on WRSM in late 2021 to address an issue I had with a certain jam game of mine. I
wanted to have a large, "open" structure for the world but did not have a simple way to avoid loading
the entire map scene at once when the Player entered the Overworld. This was not an issue in the
executable versions of the project, but caused noticeable slowdown/audio desync/other issues in the
HTML 5 export of the game, which constituted over 85% of the engagement that project received on 
itch.io. Looking back, it's the one thing I regret not having addressed in that jam experience.

At a high level, WRSM is intended to partition large 2D game spaces into smaller pieces to improve
performance in web-playable Godot projects, which consistently provide indie developers who publish 
to platforms like itch.io more engagement than projects that users must download and execute.

WRSM operates with 3 core units. These are:
	1. The Region Cell - The smallest unit. Assumed to be at least 1 in-game screen of playable space.
	2. The World Region - A collection of Region Cells that sit adjacent to each other in game space. 
	Assumed to be arranged in a grid.
	3. The World - This contains Player node, the WorldCamera (which typically follows the Player
	node), and all loaded Region Cells from the World Region the Player currently inhabits.

WRSM can accomodate many different 2D game styles, but was intended for games that resemble top-down
Zelda style games and Metroidvanias where the Player transitions between bespoke "rooms" or "screens"
to navigate the game world. 

II. How to use

First, the WorldRegion.gd script must be added as an autoload for your project.

Secondly, you need to have defined your game's base viewport resolution. You likely already have, but
if not, do it now. Once you have defined this, remember that a Region Cell is intended to be 1 in-game 
"screen." Use this knowledge to set up your 1x1 Cell template accordingly. Once you have a template 
to start from, you can build rooms in you World Region, build that Region's data, drop your player 
into a room, and start playing.

III. What's going on down there?
TBD

IV.
TBD
