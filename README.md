# TurboshookProjectTemplate

Hello! This is a template project I use to accelerate development and provide a framework for things I do in a lot of my games. The content will be subject to change over time as I add or refine implementations based on my own needs. 

# Project Settings Overrides
## Input
The following additions have been made to the built-in UI inputs:  
- `UI Accept`: A Button (Xbox A / Sony X)  
- `UI Cancel`: Back Button (Xbox B / Sony O)  
- `UI Page Up`: Left Shoulder (Xbox LB / Sony L1)  
- `UI Page Down`: Right Shoulder (Xbox RB / Sony R2)  
## Physics Layers
- `Layer 1` = "World": A common layer that I use in every project.
- `Layer 32` = "Hit": Used by the hit collider system.
## Audio Busses
- `Music`: All music to be routed through here. Routed through the `Master` bus.
- `SFX`: All sound effects to be routed through here. Routed through the `Master` bus.

# Autoloads
- `Global`: Intended to be used as a globally-scoped constant data store/lookup. This is helpful when balancing many unrelated scenes around things like the player character's base move speed, damage output, etc.
- `AudioManager`: Controls an `AudioStreamPlayer` responsible for background music and serves as a wrapper for globally-accessible `SoundQueue` and `SoundPool` instances.
- `EventManager`: TODO
- `DevUtils`: Configurable developer console and debug metric viewer.

# Components
## Standalone
- `CallbackStateMachine`: Simple FSM implementation that allows for single-script state management via callbacks. Supports state enter and exit handling. Ideal for low to medium complexity scenes.
- `InputBufferManager`: Easily track whether input events are within a certain lifetime.
- `MySprite2D`: Extended Sprite2D with extra features.
- `MySprite3D`: Extended Sprite3D with extra features.
- `Node2DPhysicsInterpolater`: Provides out-of-the-box physics interpolation to 2D scenes. Works better with follower Camera2Ds than the current built-in solutions and can be used to achieve a "pixel perfect" look.
- `Node3DPhysicsInterpolater`: Provides out-of-the-box physics interpolation to 2D scenes.
- `VectorAdjustManager`: Can be used to snap Vector2Ds to regular increments. Useful for forcing 8-way movement in top-down games, for example.
## AudioManager
- `SoundQueue`: Used to smoothly play multiple copies of a sound without cutting off a stream mid-playback.
- `SoundPool`: Can play random `SoundQueue` instances.
## FiniteStateMachine
- `FiniteStateMachine`: Robust FSM implementation that splits state logic across child `FSMState` instances. Supports state enter and exit handling. Ideal for large and complex scenes.
- `FSMState`: Used to compartmentalize a scene's state logic. `FSMState` can access the scene it controls through the `state_parent` variable.
## Hit
- `HitData`: `Resource` type that describes a hit's source, damage amount, and arbitrary String tags that can be used to implement various on-hit effects.
- `HitBox`: `Area2D`-derived scene that contains an instance of `HitData`.
- `HitBoxManager`: `Node2D`-derived scene that can instantiate and manage a `HitBox` instance.
- `HurtBox`: `Area2D`-derived scene that detects collisions with `HitBox` instances and makes their `HitData` available to their parent scene for handling.

# Configuring DevUtils
**DevUtils** is a lightweight developer console that can be accessed while the project is running in-editor in or in debug mode by pressing the `~` key. It comes with some general-purpose commands, but new commands can be added by updating the `/game/autoload/devutils/data/commands.json` file. For example:
```
"NewCommandBase": {
	"commandstring": {
		"arg_count": 0,
		"explain_text": "The text that will be printed to the console when using the explain command.",
		"missing_base_error": "Some helpful error text."
	}
}
```
Commands are organized under logical structures referred to internally as "bases" that generally describe object dependencies for a command to function properly. For example, you might consider adding the following command to refill your player character's health:
```
"Player": {
	"refill_health": {
		"arg_count": 0,
		"explain_text": "Tops of the Player's health.",
		"missing_base_error": "Player scene not active in the SceneTree."
	}
}
```
This structure communicates that the `refill_health` command requires some player object to be active in the SceneTree to function. Running valid commands related to objects that are not active in the SceneTree will result in a **missing base error** in the console output.

NOTE: All of the command fields are optional. A command that takes 0 arguments can be successfully defined with `"command_name": {}` in `commands.json`.

After the command is defined, it can be initialized from any script by accessing the `Devutils` autoload. For example, initializing the above `refill_health` command might look like this:
```
extends CharacterBody2D
class_name Player

const MAX_HEALTH: int = 3
var current_health: int = 3

func _ready() -> void:
	DevUtils.init_command("refill_health", _devutils_refill_health)

func _devutils_refill_health() -> void:
	current_health = MAX_HEALTH
```
With everything properly configured and the above player object instantiated in the SceneTree, the `_devutils_refill_health` function can be executed arbitrarily at runtime by opening the `DevUtils` console and entering `refill_health`.

Arguments can be passed to commands in the console and require minimal extra configuration. For starters, the command needs to be defined in `commands.json` with a nonzero `arg_count`, like so:
```
"Player": {
	"set_health": {
		"arg_count": 1,
		"explain_text": "Sets the Player's health to a specific value.",
		"missing_base_error": "Player scene not active in the SceneTree."
	}
}
```
The command then needs to be initialized using the optional `args: Array[ArgTypes]` argument in `Devutils.init_command()`. The size of the array must equal the `arg_type` defined for that command in `commands.json` and the members of the array must be members of the `DevUtils.ArgTypes` enum. 

Initializing the above command in the example player script from before would look like this:
```
extends CharacterBody2D
class_name Player

const MAX_HEALTH: int = 3
var current_health: int = 3

func _ready() -> void:
	DevUtils.init_command("refill_health", _devutils_refill_health)
	DevUtils.init_command("set_health", _devutils_set_health, [DevUtils.ArgTypes.INT])

func _devutils_refill_health() -> void:
	current_health = MAX_HEALTH

func _devutils_set_health(set_value: int) -> void:
	current_health = set_value
```
