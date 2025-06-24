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
- `Layer 0` = "World": A common layer that I use in every project.
- `Layer 32` = "Hit": Used by the hit collider system.
## Audio Busses
- `Music`: All music to be routed through here. Routed through the `Master` bus.
- `SFX`: All sound effects to be routed through here. Routed through the `Master` bus.

# Autoloads
- `Global`: Intended to be used as a globally-scoped constant data store. This is helpful when balancing many unrelated scenes around things like the player character's base move speed, damage output, etc.
- `AudioManager`: TODO
- `EventManager`: TODO
- `DevUtils`: TODO
