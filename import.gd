tool
extends EditorImportPlugin

func get_import_options(preset):
	return []

func get_importer_name():
	return "shoebox"

func get_option_visibility(option, options):
	return true

func get_preset_count():
	return 0

func get_preset_name(preset):
	return null

func get_recognized_extensions():
	return ["json"]

func get_resource_type():
	return "Resource"

func get_save_extension():
	return "tres"

func get_visible_name():
	return "ShoeBox Atlas"

func import(in_path, out_path, options, r_platform_variants, r_gen_files):
	var in_dir = in_path.get_base_dir()
	
	var in_data = read_json(in_path)
	if in_data[0] != OK:
		printerr("Failed to read file as JSON data.")
		return in_data[0]
	
	var json = in_data[1]
	if typeof(json) != TYPE_DICTIONARY:
		printerr("Expected JSON root to be an object.")
		return ERR_INVALID_DATA
	
	if not json.has("atlas") or typeof(json.atlas) != TYPE_STRING:
		printerr("Expected JSON file to have an \"atlas\" key with a string as its value.")
		return ERR_INVALID_DATA
	
	var in_texture_path = in_dir.plus_file(json.atlas)
	var out_texture_dir = in_dir.plus_file(in_path.get_file().get_basename())
	
	var dir = Directory.new()
	if not dir.dir_exists(out_texture_dir):
		var error = dir.make_dir(out_texture_dir)
		if error != OK:
			printerr("Failed to create atlas directory.")
			return error
	
	var in_texture = load(in_texture_path)
	if in_texture == null:
		printerr("Failed to load texture for atlas.")
		return ERR_FILE_NOT_FOUND
	
	if not json.has("sprites") or typeof(json.sprites) != TYPE_ARRAY:
		printerr("Expected JSON file to have a \"sprites\" key containing an array.")
		return
	
	var frames = []
	var error = parse_frames(json.sprites, frames)
	if error != OK:
		return error
	
	for frame in frames:
		var atlas = null
		var atlas_path = out_texture_dir.plus_file(frame[0] + ".atlastex")
		
		if ResourceLoader.has(atlas_path):
			atlas = ResourceLoader.load(atlas_path)
			if atlas == null or not (atlas is AtlasTexture):
				atlas = null
		
		if atlas == null:
			atlas = AtlasTexture.new()
		
		atlas.atlas = in_texture
		atlas.region = frame[1]
		atlas.margin = frame[2]
		
		error = ResourceSaver.save(atlas_path, atlas)
		if error != OK:
			printerr("Failed to save atlas to <%s>." % atlas_path)
			return error
	
	# The atlas itself doesn't need to output anything, but any resource import must produce something
	return ResourceSaver.save("%s.%s" % [out_path, get_save_extension()], Resource.new())

func decode_rect(rect):
	if typeof(rect) != TYPE_ARRAY or len(rect) != 4:
		printerr("Expected rectangle value to be an array of 4 values.")
		return ERR_INVALID_DATA
	
	for value in rect:
		if typeof(value) != TYPE_REAL:
			printerr("Expected rectangle value to contain all numbers.")
			return ERR_INVALID_DATA
	
	return Rect2(rect[0], rect[1], rect[2], rect[3])

func parse_frames(json, out):
	for sprite in json:
		if typeof(sprite) != TYPE_DICTIONARY:
			printerr("Expected value in \"sprites\" key to be an object.")
			return ERR_INVALID_DATA
		
		if not sprite.has("id") or typeof(sprite.id) != TYPE_STRING:
			printerr("Expected sprite object to have an \"id\" key containing a string.")
			return ERR_INVALID_DATA
		
		var id = sprite.id
		
		if not sprite.has("region") or typeof(sprite.region) != TYPE_ARRAY:
			printerr("Expected sprite object to have a \"region\" key containing an array of 4 values.")
			return ERR_INVALID_DATA
		
		if not sprite.has("source") or typeof(sprite.source) != TYPE_ARRAY:
			printerr("Expected sprite object to have a \"source\" key containing an array of 4 values.")
			return ERR_INVALID_DATA
		
		var region = decode_rect(sprite.region)
		if typeof(region) != TYPE_RECT2:
			return region
		
		var source = decode_rect(sprite.source)
		if typeof(source) != TYPE_RECT2:
			return source
		
		var margin = Rect2(source.position,
		                   source.size - region.size)
		
		out.append([id, region, margin])
	
	return OK

func read_file(path):
	var file = File.new()
	
	var error = file.open(path, File.READ)
	if error != OK:
		return [error, null]
	
	var content = file.get_as_text()
	
	error = file.get_error()
	if error != OK:
		return [error, null]
	
	file.close()
	return [OK, content]

func read_json(path):
	var data = read_file(path)
	if data[0] != OK:
		return [data[0], null]
	
	var parse = JSON.parse(data[1])
	if parse.error != OK:
		return [parse.error, null]
	else:
		return [OK, parse.result]
