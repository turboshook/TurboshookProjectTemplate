# TurboshookProjectTemplate

Hello! This is a template project I use to accelerate development and provide a framework for things I do in a lot of my games. The content will be subject to change over time as I add or refine implementations based on my own needs. 

# Creating a New Project
I like to keep a clean version of this repository in a local directory and make copies from it to start a new project. This process can be automated with `new_project.py`, which copies all project files to a new sibling directory without any of this repository's Git data. 

For Windows users: 
1. Clone this repository.
2. Open PowerShell/Command Prompt in the template root directory.
3. Run `python new_project.py`.
4. Provide the new project name when prompted. The script writes this to `project.godot`.
5. After successfully copying, open the Godot Project Manager and scan the directory the template folder was copied to in order to detect the project.
6. Make your game.

# Project Settings Overrides
## Input
The following additions have been made to the built-in UI inputs:  
- `UI Accept`: A Button (Xbox A / Sony X)  
- `UI Cancel`: Back Button (Xbox B / Sony O)  
- `UI Page Up`: Left Shoulder (Xbox LB / Sony L1)  
- `UI Page Down`: Right Shoulder (Xbox RB / Sony R2)  
## Physics Layers
- `Layer 1` = "World": A common layer that I use in every project.
- `Layer 31` = Used by the `RigidBodyPickUp` component system. 
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
- `CameraController`: A simple Camera3D manager solution for implementing mouse look in first-person perspective.
- `HealthManager`: Can be used to quickly implement hit point management.
- `InputBufferManager`: Easily track whether input events are within a certain lifetime.
- `MySprite2D`: Extended Sprite2D with extra features.
- `MySprite3D`: Extended Sprite3D with extra features.
- `Node2DPhysicsInterpolater`: Provides out-of-the-box physics interpolation to 2D scenes. Works better with follower Camera2Ds than the current built-in solutions and can be used to achieve a "pixel perfect" look. **Godot's native physics interpolation is a suprior solution in most cases.**
- `Node3DPhysicsInterpolater`: Provides out-of-the-box physics interpolation to 3D scenes. **Godot's native physics interpolation is a suprior solution in most cases.**
- `PlayerDetector`: `Area3D` subclass to speed up the common task of creating collisions areas to detect the Player's phyiscal presence in the world. Includes optional ray casting logic to detect world collisions along line-of-sight.
- `SimpleSceneDestroyer`: A basic starting point for more sophisticated scene freeing.
- `VectorAdjustManager`: Can be used to snap Vector2Ds to regular increments. Useful for forcing 8-way movement in top-down games, for example.
- `WorldEventActivator3D`: Basis for a collision-based world event management system. 
- `WorldOcclusionDetector`: A slightly more robust raycast manager that is intended to detect physical (detectable via physics collisions) obstructions occluding the parent scene from the current active `Camera3D` instance. This can be used with other visibility checks to implement SCP-173/Weeping Angel-style behavior.

## Sound
- `SoundQueue`: Used to smoothly play multiple copies of a sound without cutting off a stream mid-playback.
- `SoundPool`: Can play random `SoundQueue` instances.
## FiniteStateMachine
- `FiniteStateMachine`: Robust FSM implementation that splits state logic across child `FSMState` instances. Supports state enter and exit handling. Ideal for large and complex scenes.
- `FSMState`: Used to compartmentalize a scene's state logic. `FSMState` can access the scene it controls through the `state_parent` variable.
## Hit
- `HitData`: `Resource` type that describes a hit's source, damage amount, and arbitrary String tags that can be used to implement various on-hit effects.
- `HitBox2D/3D`: `Area2D`/`Area3D`-derived scene that contains an instance of `HitData`.
- `HitBoxManager2D/3D`: `Node2D`/`Node3D`-derived scene that can instantiate and manage a `HitBox2D/3D` instance.
- `HurtBox2D/3D`: `Area2D`/`Area3D`-derived scene that detects collisions with `HitBox2D/3D` instances and makes their `HitData` available to their parent scene for handling.
## Rigid Body Pick Up
- `RigidBodyPickUpComponent3D`: An `Area3D` scene that defines a collision object which `RigidBodyPickUpManager3D` can interact with.
- `RigidBodyPickUpManager3D`: A `Node3D` scene that allows some game entity to pick up, carry, and throw `RigidBody3D` objects that have a child instance of `RigidBodyPickUpComponent3D` without reparenting. This can be used in a variety of gameplay contexts, but was written specifically to replicate the gameplay of manipulating physics objects with a first-person character controller in games such as *Half-Life 2* and *Amnesia: The Dark Descent*.

# Utility Scenes
- `FirstPersonController`: A simple first-person character controller using only default inputs and implemented with `CameraController` component.
- `FreeCamera3D`: A controller for a `Camera3D` instance that can freely fly around a 3D environment intended to be used as a debug tool.
- `SceneTransitionManager`: A `CanvasLayer` scene with a simple interface to manage screen fade in/fade out between scene changes. 

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
The command then needs to be initialized using the optional `args: Array[ArgTypes]` argument in `Devutils.init_command()`. The size of the array must equal the `arg_count` defined for that command in `commands.json` and the members of the array must be members of the `DevUtils.ArgTypes` enum. 

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
