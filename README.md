# ShoeBox Importer for Godot 3

This is an addon for Godot 3 projects which simplifies the process of importing texture atlases made by the sprite sheet tool provided by [ShoeBox](https://renderhjs.net/shoebox/). This is a free-to-use utility which supports the generation of texture atlases, among other things.

This addon currently only supports importing sprite sheets generated using ShoeBox.

## Installation

The contents of this repository should be placed in the addons/shoebox directory of your project, such that the plugin.cfg file in the repository is located at `res://addons/shoebox/plugin.cfg`.

Once this is done, go to Project > Project Settings > Plugins and activate the "ShoeBox Importer" plug-in.

## Creating an Atlas

ShoeBox allows the format of the data file to be customized via its format strings. This addon includes `godot.sbx`, which is a ShoeBox settings file which contains the necessary format strings to export the data about the atlas in the JSON format.

Once ShoeBox is installed, `godot.sbx` can be opened with ShoeBox to load the base settings. The most important part is the file format fields; those should not be changed. Any other settings can be changed to suit the project.  Once configured, the image files to include in the atlas can be dropped onto ShoeBox's Sprite Sheet tool to generate the texture atlas (name.png) and its JSON file (name.json).

These files should then be moved into the Godot project.

You can (and probably should) save your settings as an sbx file to avoid mistakes when changes are made to any of the source images. You may also want to export a batch script which will repack the images.

## Importing an Atlas

Once a texture atlas and its JSON file are in the Godot project, textures can be imported by double-clicking the JSON file in Godot's filesystem view, then selecting "ShoeBox Atlas " as the type to import in the Import pane.

This will create an .atlastex file for each of the sprites in the atlas, and place them all in a subdirectory of the directory containing the JSON file. The subdirectory will be named the same as the JSON file, but without the extension. For instance, if the JSON file is located at assets/game-sprites.json relative to the project root, then all the textures in the atlas will be located at assets/game-sprites/\*.atlastex.

Any storage settings (e.g. compression, filtering, etc.) can be configured on the texture atlas image itself, and will apply to all sprites which are contained in that texture. If you want to use separate settings for your sprites (e.g. some should be filtered and some shouldn't), they will need to be in separate atlases. This is not really a limitation of this addon; that's just how Godot's AtlasTexture works.

## Notes

### License

This addon is licensed with the zlib/libpng license. This is the most permissive license I could find that was actually a license (and thus valid anywhere). See the LICENSE file for details.

### JSON Format

The JSON file generated by ShoeBox has a comma after the last value of the "sprites" array, so technically it's not correct JSON. The way that ShoeBox format strings work, there is no way to avoid this. Fortunately, Godot's JSON parser accepts it anyway.

The default format for the sprite sheet file that ShoeBox uses is XML; this could also be used (Godot does provide a SAX-style XML parser), but for simplicity's sake, I opted to use JSON instead.
