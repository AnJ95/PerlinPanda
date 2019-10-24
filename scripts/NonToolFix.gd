extends Object

static func g():
	if !Engine.editor_hint:
		return g
	else:
		return {"level":1, "unlocked_buyables":[]}