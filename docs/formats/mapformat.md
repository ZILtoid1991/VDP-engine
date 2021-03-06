Prerequirements:

* Knowledge of SDLang (https://sdlang.org/)
* Basic knowledge of the engine architecture

This document is not finished, although I plan to minimize changes that would break a lot of things.

Extension: `.XMF` (Extendible Map Format)

Naming conventions:

* PascalCase for tags and namespaces.
* camelCase for attributes.
* Use of namespaces in attributes should be avoided.

Conventions with value vs. attribute usage:

* Values are used for mandatory values.
* Attributes are used for optional values.

# Metadata

* Has no namespace
* Position restraint: in root tag, preferrably the first tag in the file if the file doesn't start with a comment

Contains various metadata for the map.

### Version

`Version 1 0`

Contains the format version information. `value[0]` is the major version, `value[1]` is the minor version.

### ExtType

`ExtType "nameOfYourGame" 1 1 7`

Identifies what kind of extensions this file has. `value[0]` is universally a string, the other values are not bound, can be used for eg. version information of the given extension.

### Software

`Software "PixelPerfectEditor" 0 9 4`

Identifies the last software that was used to edit this file. `value[0]` is the name of the editor, values 1 through 3 are version numbers (major, minor, and revision).

### Resolution

`Resolution 424 240`

Sets the resolution used to display the map.

### Other standardized tags that can appear in this chunk

All of these tags are single value, so they will have a shorter explanation. If any of these are null, then they should be absent.

* `Name`: Name of the map.
* `Comment`: A comment about the map.
* `Creator`: Name of the creator.
* `Team`: Name of the creator team.
* `DateOfCreation`: Date of creation.
* `DateOfLastModification`: Date of last modification.

# Namespace 'Layer'

* Position constraints: In root tag, preferrably in order of display from bottom to top.

Contains data about the layers. First value is always the layer name, second value is always the priority.

## Tile

Contains data related to tile layers.

As of version 1.0, TileLayers can have additional ancillary tags as long as they don't have a collision with others within a single layer. Within all those tags, there can be even more child tags with the same rule. Namespaces are restricted to internal use.

`Layer:Tile "Background 0" 0 32 32 256 256`

`value[0]` is the name of the layer, `value[2]` and `value[3]` are horizontal and vertical tile sizes, `value[4]` and `value[5]` are horizontal and vertical map sizes

### RenderingMode

`RenderingMode "AlphaBlending"`

Sets the rendering mode of the layer. Currently accepted values are: "Copy", "Blitter", "AlphaBlend", "Add", "AddBl", "Multiply", "MultiplyBl", "Subtract", "SubtractBl", "Diff", "DiffBl", "Screen", "ScreenBl", "AND", "OR", "XOR".

## Sprite

Contains data related to sprite layers.

As of version 1.0, SpriteLayers can have additional ancillary tags as long as they don't have a collision with others within a single layer. Within all those tags, there can be even more child tags with the same rule. Namespaces are restricted to internal use.

`Layer:Sprite "Playfield A" 1`

### RenderingMode

`RenderingMode "AlphaBlending"`

Sets the rendering mode of the layer. Currently accepted values are: "Copy", "Blitter", "AlphaBlending", "Add", "Multiply", "Subtract", "Diff", "Screen", "AND", "OR", "XOR".

# Namespace 'Embed'

* Position constraints: Within the tag of any layer and sometimes other tags, with no preferrence of order.

Specifies data that is embedded within this file. These can be: Mapping data, names and IDs of individual tiles, scripting files, etc.

## TileData

`Embed:TileData`

Stores embedded tiledata. Should be within a `File:TileSource` tag.

Has a single kind of nameless tag in the given format:

`2 2 "sci-fi-tileset.tga0x0002"`

Explanations for values in order:

1) The ID of the tile. Must be between 0 and 65535.
2) Determines which tile is requested from the sheet in left-to-right top-to-bottom order.
3) The name of the tile.

## MapData

`Embed:MapData []`

Stores embedded mapdata encoded in BASE64.

## Palette

`Embed:Palette [] offset=768`

Stores palette embedded as BASE64 code. Can have the attribute `offset`, which determines where the palette should be loaded in the raster.

## Script

`Embed:Script [] lang="dbasic"`

Stores a script for a layer or an object.

# Namespace 'File'

Defines external file sources for the map.

Tags in the `File` namespace can have the `dataPakSrc` attribute, which specifies the datapak file the file is in.

## MapData

`File:MapData "64.map"`

Determines where the map file of the layer can be found. Must be part of a `Layer:Tile` tag.

## Palette

`File:Palette "../assets/sci-fi-tileset.tga" palShift=5 offset=32`

Specifies the bitmap file that contains a palette needs to be loaded. Attribute `palShift` limits the size of the palette to avoid overwriting a previously loaded palette that comes after it, `offset` sets where the palette should be stored on the raster.

## TileSource

`File:TileSource "../assets/sci-fi-tileset.tga" palShift=5`

Specifies the bitmap file that contains the tiles. Must be part of a `Layer:Tile` tag. Can contain the `Embed:TileInfo` tag if the file doesn't have some extension to contain the tileinfo. Attribute `palShift` sets the amount of palette shift for all imports from that file.

## SpriteSource

`File:SpriteSource 32 "../assets/dlangman.tga" name="dlangman" horizOffset=0 vertOffset=0 width=32 height=32` or `File:SpriteSource 32 "../assets/sprites.tga" name="dlangman" sprite="dlangman"` if file has sprite sheet or tile extensions.

Specifies the bitmap for a sprite. 1st value contains the material ID, 2nd value contains the filename. The `name` attribute names the sprite. If the file doesn't have sprite sheet or tile extensions, then the attributes `horizOffset`, `vertOffset`, `width`, and `height` can specify such things; otherwise `sprite` attribute can be used with a name. 

## SpriteSheet

`File:SpriteSheet "../assets/sprites.tga"`

Imports a whole spritesheet. If the target file doesn't have sprite or tile extensions, then this tag must have child tag(s) to describe the sprites, also can be used to override the file's own extension.

### SheetData

`SheetData id=56 name="Spritesheet"`

The `id` attribute sets the ID of the sheet (otherwise it's zero), the `name` sets the name of the spritesheet. Can be left out if needed.

The tag must have at least one unnamed child tag to describe sprites.

`32 16 16 32 32 displayOffsetX=-8 displayOffsetY=2 name="dlangman"`

Value notation:

1) Sprite ID. Must be unique.
2) X position where the sprite begins.
3) Y position where the sprite begins.
4) Width of the sprite.
5) Height of the sprite.

Attributes `displayOffsetX` and `displayOffsetY` set the offset of the sprites when being displayed. `name` sets the name of the sprite, otherwise a generated name sill be used in the editor.

## Script

`File:Script "../script/something" lang="qscript"`

Specifies a script for a layer or object.

# Namespace 'Object'

* Position constraints: Within the tag of any layer, with no preferrence of order.

Contains data related to a single object. These objects can be used for collision detection, events, sprites (only on sprite layers), etc.

First value is a string, the name of the instance, the second one is a priority ID (must be unique per layer!). Third value is usually the identifier of source.

Ancilliary tags are currently handled differently than in layers, meaning that more complex tag structure can be used. Processing of those should be done by the end user.

## Box

`Object:Box "nameOfObject" 15 22 22 32 30`

Defines a box object. Can be used for various purposes, e.g. event markdown, clipping on tile layers towards sprites, etc.

Value notation:

1) The name of the object.
2) Unique ID that belongs to the object.
3) Left.
4) Top,
5) Right,
6) and Bottom coordinates of the object.

## Sprite

`Object:Sprite "playerObject" 0 0 200 200 scaleHoriz=1024 scaleVert=1024 masterAlpha=250`

Defines a sprite object. Only can be used on sprite layers.

Value notation:

1) The name of the object.
2) Unique sprite ID with priority in mind.
3) Sprite source identificator.
4) X coordinate.
5) Y coordinate.

`scaleHoriz` and `scaleVert` sets the horizontal and vertical scaling values with 1024 (1.0) being the default one. `masterAlpha` sets the master alpha value for rendering to the raster.

### RenderingMode

`RenderingMode "AlphaBlending"`

Sets the rendering mode of the sprite. Currently accepted values are: "Copy", "Blitter", "AlphaBlending", "Add", "Multiply", "Subtract", "Diff", "Screen", "AND", "OR", "XOR".