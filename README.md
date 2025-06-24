# MyProjectTemplate

Template project to accelerate game development and provide a flexible for framework for common operations.

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
