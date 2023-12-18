
# SimpleZone

SimpleZone simplifies the process of tracking and managing BaseParts within set zones, making it versatile for various in-game mechanics like capture points, proximity-based effects, and more.


## Usage/Examples

1. **Creating a Zone Instance**:
```lua
local Zone = require(PathToZoneModule)
local myZone = Zone.new(Vector3.new(0, 10, 0), 15, "MyZoneName")
```

2. **Tracking Parts:**
```lua
myZone:track(partToTrack)
```

3. **Adding Callbacks:**
```lua
myZone:onPartEnter(partToTrack, function()
    -- Handle entry event
end)
```

4. **Checking Point in Zone:**
```lua
local isInZone = myZone:isPointInZone(Vector3.new(5, 10, 5))
```

5. **Destroying the Zone:**
```lua
myZone:destroy()
```
## API Reference

#### Class Methods

- **new(position: Vector3, radius: number, name: string)**:
  - Creates a new Zone instance.
  - Parameters:
    - `position`: Center of the zone as a Vector3.
    - `radius`: Radius of the zone as a number.
    - `name`: Name of the zone as a string.

- **track(part: BasePart, isCamera: boolean?)**:
  - Tracks a BasePart or Camera within the zone.
  - Parameters:
    - `part`: BasePart or Camera to track.
    - `isCamera` (optional): Boolean flag to track a camera.

- **untrack(part: BasePart)**:
  - Stops tracking a BasePart within the zone.
  - Parameter:
    - `part`: BasePart to stop tracking.

- **onPartEnter(part: BasePart, callback)**:
  - Connects a callback function to the entry event of a tracked part.
  - Parameters:
    - `part`: BasePart being tracked.
    - `callback`: Function to execute on entry event.

- **onPartExit(part: BasePart, callback)**:
  - Connects a callback function to the exit event of a tracked part.
  - Parameters:
    - `part`: BasePart being tracked.
    - `callback`: Function to execute on exit event.

- **isPointInZone(position: Vector3)**:
  - Checks if a given point is within the zone.
  - Parameter:
    - `position`: Vector3 position to check.

- **destroy()**:
  - Cleans up the Zone instance, disconnecting all connections and signals.