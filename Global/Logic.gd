extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
const Clue = preload("res://Scripts/Clue.gd")
var selected = []
var field = []
var solution = []
const tiles = ["1", "2", "3", "4", "5", "6"]
const rows = ["A", "B", "C", "D", "E", "F"]
var ingame = []
var solved = []
var rng = RandomNumberGenerator.new()

var clues = {}
# Called when the node enters the scene tree for the first time.
func _ready():
	seed("TestLevel".hash())
	_createSolution()
	_createField()
	_createClues()
	var checksolved = true
	for col in range(6):
		for row in range(6):
			if (solution[col][row] != selected[col][row]): solved = false
	for type in clues:
		print("Generated %s clues with type %s" % [clues[type].size(), type])
	_reduceClues()
	for type in clues:
		print("Reduced to %s clues with type %s" % [clues[type].size(), type])	

func _createField():
	field = []
	selected = []
	solved = []
	ingame = []
	for col in range(6):
		field.append([])
		selected.append([])
		for row in range(6):
			field[col].append(_rowTiles(row))
			selected[col].append(null)
			ingame.append(solution[col][row])

func _createSolution():
	for _i in range(6):
		solution.append([])
	for row in range(6):
		var ans = _rowTiles(row)
		ans.shuffle()
		for col in range(6):
			solution[col].append(ans[col])


func _createClues():
	for type in GL.CLUETYPE.values():
		clues[type] = []
	while !_isSolved():		
		_trySolve()
		_createClue()
	
	

func _reduceClues():
	for type in GL.CLUETYPE.values():
		for clue in clues[type]:
			_enableClues()
			clue.enabled = false
			_createField()
			_trySolve()
			if (_isSolved()): clue.toDel = true
	for type in GL.CLUETYPE.values():
		for clue in range(clues[type].size() - 1, -1, -1):
			if (clues[type][clue].toDel): clues[type].remove(clue)
			

func _enableClues():
	for type in GL.CLUETYPE.values():
		for clue in clues[type]:
			if (!clue.toDel): clue.enabled = true

func _trySolve():	
		var changed = true
		while (changed == true):
			changed = false
			if (_checkLast()):
				changed = true
			if (_checkOnly()):
				changed = true
			if (_checkClues()): changed = true		
	
func _checkClues():
	var changed = false
	for clue in clues[GL.CLUETYPE.COLUMN]:
		if !clue.enabled: continue
		if (_checkClueCol(clue)): changed = true
	for clue in clues[GL.CLUETYPE.NEAR]:
		if !clue.enabled: continue
		if (_checkClueNear(clue)): changed = true
	for clue in clues[GL.CLUETYPE.BETWEEN]:
		if !clue.enabled: continue
		if (_checkClueBetween(clue)): changed = true
	for clue in clues[GL.CLUETYPE.TOLEFT]:
		if !clue.enabled: continue
		if (_checkClueToLeft(clue)): changed = true
	for clue in clues[GL.CLUETYPE.NOTNEAR]:
		if !clue.enabled: continue
		if (_checkClueNotNear(clue)): changed = true
	for clue in clues[GL.CLUETYPE.NOTCOL]:
		if !clue.enabled: continue
		if (_checkClueNotCol(clue)): changed = true
	for clue in clues[GL.CLUETYPE.NOTBETWEEN]:
		if !clue.enabled: continue
		if (_checkClueNotBetween(clue)): changed = true
	for clue in clues[GL.CLUETYPE.SELECTED]:
		if !clue.enabled: continue
		var pos = _findInSolution(clue.tile1)
		_selectTile(pos[0], pos[1], clue.tile1)
		changed = true
		clue.enabled = false
	return changed

func _checkClueNotBetween(clue:Clue):
	var changed = false
	if (clue.tile1 in solved) && (clue.tile3 in solved):
		clue.enabled = false
		var pos1 = _findInSolution(clue.tile1)
		var pos2 = _findInSolution(clue.tile3)
		if (_removeFromField((pos1[0] + pos2[0]) / 2, clue.tile2)): changed = true
		return changed
	if (clue.tile2 in solved):
		var pos = _findInSolution(clue.tile2)
		var col = pos[0]
		if (!_tilePresent(col + 3, clue.tile3)):
			if (_removeFromField(col + 1, clue.tile1)): changed = true
		if (!_tilePresent(col - 3, clue.tile3)):
			if (_removeFromField(col - 1, clue.tile1)): changed = true
		if (!_tilePresent(col + 3, clue.tile1)):
			if (_removeFromField(col + 1, clue.tile3)): changed = true
		if (!_tilePresent(col - 3, clue.tile1)):
			if (_removeFromField(col - 1, clue.tile3)): changed = true		
	for col in range(6):
		if !(_tilePresent(col + 2, clue.tile3) || _tilePresent(col - 2, clue.tile3)):
			if (_removeFromField(col + 1, clue.tile1)): changed = true
		if !(_tilePresent(col + 2, clue.tile1) || _tilePresent(col - 2, clue.tile1)):
			if (_removeFromField(col + 1, clue.tile3)): changed = true
	return changed		

func _checkClueNotCol(clue:Clue):
	var changed = false
	if (clue.tile1 in solved) && (clue.tile2 in solved):
		clue.enabled = false
		return false
	if (clue.tile1 in solved):
		var pos = _findInSolution(clue.tile1)
		if (_removeFromField(pos[0], clue.tile2)): changed = true 
	if (clue.tile2 in solved):
		var pos = _findInSolution(clue.tile2)
		if (_removeFromField(pos[0], clue.tile1)): changed = true
	return changed
	
func _checkClueNotNear(clue:Clue):
	var changed = false
	if (clue.tile1 in solved) && (clue.tile2 in solved):
		clue.enabled = false
		return false
	if (clue.tile1 in solved):
		var pos = _findInSolution(clue.tile1)
		if (_removeFromField(pos[0] - 1, clue.tile2)): changed = true 
		if (_removeFromField(pos[0] + 1, clue.tile2)): changed = true
	if (clue.tile2 in solved):
		var pos = _findInSolution(clue.tile2)
		if (_removeFromField(pos[0] - 1, clue.tile1)): changed = true 
		if (_removeFromField(pos[0] + 1, clue.tile1)): changed = true
	return changed
	
func _checkClueToLeft(clue:Clue):
	var changed = false
	if (clue.tile1 in solved) && (clue.tile2 in solved) && (clue.tile3 in solved):
		clue.enabled = false
		return false
	if (clue.tile1 in solved):
		clue.enabled = false
		var pos = _findInSolution(clue.tile1)
		for col in range(0, pos[0]+1):
			if (_removeFromField(col, clue.tile2)): changed = true
		return changed
	if (clue.tile2 in solved):
		clue.enabled = false
		var pos = _findInSolution(clue.tile2)
		for col in range(pos[0], 6):
			if (_removeFromField(col, clue.tile1)): changed = true
		return changed
	for col in range(6):
		var has = false
		for l in range(0, col):
			if (_tilePresent(l, clue.tile1)): has = true
		if (!has):
			if (_removeFromField(col, clue.tile2)): changed = true
		has = false
		for r in range(col + 1 , 6):
			if (_tilePresent(r, clue.tile2)): has = true
		if (!has):
			if (_removeFromField(col, clue.tile1)): changed = true
	return changed
	
func _checkClueBetween(clue:Clue):
	var changed = false
	if (clue.tile1 in solved) && (clue.tile2 in solved) && (clue.tile3 in solved):
		clue.enabled = false
		return false
	for col in range(6):
		if !(_tilePresent(col - 2, clue.tile3) || _tilePresent(col + 2, clue.tile3)):
			if (_removeFromField(col, clue.tile1)): changed = true
		#if !(_tilePresent(col - 2, clue.tile3) || _tilePresent(col + 1, clue.tile2)):
		#	if (_removeFromField(col, clue.tile1)): changed = true
		#if !(_tilePresent(col + 2, clue.tile3) || _tilePresent(col - 1, clue.tile2)):
		#	if (_removeFromField(col, clue.tile1)): changed = true
		if !(_tilePresent(col - 1, clue.tile2) || _tilePresent(col + 1, clue.tile2)):
			if (_removeFromField(col, clue.tile1)): changed = true	
			if (_removeFromField(col, clue.tile3)): changed = true
		if !(_tilePresent(col - 2, clue.tile1) || _tilePresent(col + 2, clue.tile1)):
			if (_removeFromField(col, clue.tile3)): changed = true		
		#if !(_tilePresent(col - 2, clue.tile1) || _tilePresent(col + 1, clue.tile2)):
		#	if (_removeFromField(col, clue.tile3)): changed = true
		#if !(_tilePresent(col + 2, clue.tile1) || _tilePresent(col - 1, clue.tile2)):
		#	if (_removeFromField(col, clue.tile3)): changed = true
		if !(_tilePresent(col - 1, clue.tile3) || _tilePresent(col + 1, clue.tile3)):
			if (_removeFromField(col, clue.tile2)): changed = true
		if !(_tilePresent(col - 1, clue.tile1) || _tilePresent(col + 1, clue.tile1)):
			if (_removeFromField(col, clue.tile2)): changed = true
		if !(_tilePresent(col - 1, clue.tile1) || _tilePresent(col - 1, clue.tile3)):
			if (_removeFromField(col, clue.tile2)): changed = true
		if !(_tilePresent(col + 1, clue.tile1) || _tilePresent(col + 1, clue.tile3)):
			if (_removeFromField(col, clue.tile2)): changed = true	
	return changed
	
func _checkClueNear(clue:Clue):
	var changed = false
	if (clue.tile1 in solved) && (clue.tile2 in solved):
		clue.enabled = false
		return false
	if (clue.tile1 in solved):
		var pos = _findInSolution(clue.tile1)
		var col1 = pos[0]
		for col in range(6):
			if (col != col1 + 1  || col != col1 - 1):
				_removeFromField(col, clue.tile2)
		clue.enabled = false		
		return true
	if (clue.tile2 in solved):
		var pos = _findInSolution(clue.tile2)
		var col1 = pos[0]
		for col in range(6):
			if (col != col1 + 1  || col != col1 - 1):
				_removeFromField(col, clue.tile1)
		clue.enabled = false
		return true
	for col in range(6):
		if !(_tilePresent(col - 1, clue.tile1) || _tilePresent(col + 1, clue.tile1)):
			if _removeFromField(col, clue.tile2) : changed = true
		if !(_tilePresent(col - 1, clue.tile2) || _tilePresent(col + 1, clue.tile2)):
			if _removeFromField(col, clue.tile1): changed = true
	return changed
	
func _checkClueCol(clue:Clue):
	var changed = false
	if (clue.tile1 in solved) && (clue.tile2 in solved): 
		clue.enabled = false
		return false
	if (clue.tile1 in solved):
		var pos = _findInSolution(clue.tile2)
		_selectTile(pos[0], pos[1], clue.tile2)
		return true
	if (clue.tile2 in solved):
		var pos = _findInSolution(clue.tile1)
		_selectTile(pos[0], pos[1], clue.tile1)
		return true
	for col in range(6):
		if !_tilePresent(col, clue.tile1):
			if _removeFromField(col, clue.tile2): changed = true
		if !_tilePresent(col, clue.tile2):
			if _removeFromField(col, clue.tile1): changed = true
	return changed	

func _createClue():
	if (ingame.size() == 0): return
	var clue = Clue.new()
	clue.type = _getClueType()
	var tile = ingame[rng.randi() % ingame.size()]
	var place = _findInSolution(tile)
	var col = place[0]
	var row = place[1]
	if clue.type == GL.CLUETYPE.COLUMN:
		clue.tile1 = tile
		var row2 = rng.randi_range(0, 5)
		while (row2 == row):
			row2 = rng.randi_range(0, 5)
		clue.tile2 = solution[col][row2]	
	elif clue.type == GL.CLUETYPE.NEAR:
		var arr = [col+1, col-1]
		arr.shuffle()
		var col2 = arr[0]
		if col2 == -1: col2 = 2
		if col2 == 6: col2 = 4
		var row2 = rng.randi_range(0, 5)
		arr = [tile, solution[col2][row2]]
		arr.shuffle()
		clue.tile1 = arr[0]
		clue.tile2 = arr[1]
	elif clue.type == GL.CLUETYPE.BETWEEN:
		var row2 = rng.randi_range(0, 5)
		var row3 = rng.randi_range(0, 5)
		if col == 0:
			clue.tile2 = solution[col+1][row2]
			var arr = [tile, solution[col+2][row3]]
			arr.shuffle()
			clue.tile1 = arr[0]
			clue.tile3 = arr[1]
		if col == 5:
			clue.tile2 = solution[col-1][row2]
			var arr = [tile, solution[col-2][row3]]
			arr.shuffle()
			clue.tile1 = arr[0]
			clue.tile3 = arr[1]
		else:
			clue.tile2 = tile
			var arr = [solution[col+1][row3], solution[col-1][row3]]
			arr.shuffle()
			clue.tile1 = arr[0]
			clue.tile3 = arr[1]
	elif clue.type == GL.CLUETYPE.TOLEFT:
		var row2 = rng.randi_range(0,5)
		var col2 = rng.randi_range(0,5)
		while (col2 == col): col2 = rng.randi_range(0, 5)
		if col2 < col:
			clue.tile1 = solution[col2][row2]
			clue.tile2 = tile
		else:
			clue.tile1 = tile
			clue.tile2 = solution[col2][row2]	
	elif clue.type == GL.CLUETYPE.NOTCOL:
		var row2 = rng.randi_range(0, 5)
		while (row2 == row): row2 = rng.randi_range(0, 5)
		var col2 = rng.randi_range(0, 5)
		while (col2 == col): col2 = rng.randi_range(0, 5)
		clue.tile1 = tile
		clue.tile2 = solution[col2][row2]
	elif clue.type == GL.CLUETYPE.NOTNEAR:
		var row2 = rng.randi_range(0, 5)
		var col2 = rng.randi_range(0, 5)
		while (col2 == col + 1 || col2 == col - 1): col2 = rng.randi_range(0, 5)
		while (col == col2 && row2 == row): row2 = rng.randi_range(0, 5)
		var arr =  [tile, solution[col2][row2]]
		arr.shuffle()
		clue.tile1 = arr[0]
		clue.tile2 = arr[1]
	elif clue.type == GL.CLUETYPE.NOTBETWEEN:
		var arr = []
		var row2 = rng.randi_range(0, 5)
		var row3 = rng.randi_range(0, 5)
		if (col - 2) >= 0: arr.append(col - 2)
		if (col + 2) <= 5: arr.append(col + 2)
		arr.shuffle()
		var col3 = arr[0]
		var col2 = rng.randi_range(0, 5)
		while (col2 == (col3 + col) / 2 ): col2 = rng.randi_range(0, 5)
		arr = [tile, solution[col3][row3]]
		arr.shuffle()
		clue.tile1 = arr[0]
		clue.tile2 = solution[col2][row2]
		clue.tile3 = arr[1]
	elif clue.type == GL.CLUETYPE.SELECTED:
		clue.tile1 = tile
	clues[clue.type].append(clue)	
#	var new = true	
#	for old in clues[clue.type]:
#		if (old.tile1 == clue.tile1 && old.tile2 == clue.tile2 && old.tile3 == clue.tile3):
#			new = false
#			break
#		if (clue.type != GL.CLUETYPE.NOTBETWEEN && clue.type != GL.CLUETYPE.BETWEEN && clue.type != GL.CLUETYPE.TOLEFT):
#			if (old.tile1 == clue.tile2 && old.tile2 == clue.tile1):
#				new = false
#				break
#		if (clue.type == GL.CLUETYPE.NOTBETWEEN || clue.type == GL.CLUETYPE.BETWEEN):
#			if (old.tile1 == clue.tile3 && old.tile2 == clue.tile2 && old.tile3 == clue.tile1):
#				new = false
#				break
#	if new: clues[clue.type].append(clue)
	
func _getClueType():
	var num = rng.randi_range(0, 100)
	if (num < 30): return GL.CLUETYPE.NEAR
	elif (num < 60): return GL.CLUETYPE.COLUMN
	elif (num < 90): return GL.CLUETYPE.BETWEEN
	elif (num < 0): return GL.CLUETYPE.TOLEFT
	elif (num < 0): return GL.CLUETYPE.NOTBETWEEN
	elif (num < 0): return GL.CLUETYPE.NOTCOL
	elif (num < 0): return GL.CLUETYPE.NOTNEAR
	return GL.CLUETYPE.SELECTED

func _selectTile(col, _row1, tile):
	var row = rows.find(tile.left(1))
	ingame.erase(tile)
	solved.append(tile)
	selected[col][row] = tile
	field[col][row] = []
	for i in range (6):
			field[i][row].erase(tile)
	
func _checkLast():
	var changed = false
	for col in range (6):
		for row in range(6):
			if field[col][row].size() == 1:
				_selectTile(col, row, field[col][row][0])
				changed = true
	return changed
	
func _checkOnly():
	var changed = false
	for row in range(0, 6):
		for tile in _rowTiles(row):
			if !ingame.has(tile): continue
			var count = 0
			var seen = 0
			for col in range(6):
				if (field[col][row].has(tile)):
					count += 1
					seen = col			
			if (count == 1):
				_selectTile(seen, row, tile)
				changed = true
	return changed

func _rowTiles(row):
	var ans = []
	for i in range(6):
		ans.append(rows[row] + tiles[i])
	return ans

func _isSolved():
	return (ingame.size() == 0)
	
func _removeFromField(col, tile):
	if (col < 0 || col > 5): return false
	var row = rows.find(tile.left(1))
	var has = field[col][row].has(tile)
	if has:	field[col][row].erase(tile)
	return has
	
func _tilePresent(col, tile):
	if (col < 0 || col > 5): return false
	var row = rows.find(tile.left(1))
	return (field[col][row].has(tile) || selected[col][row] == tile)

func _findInSolution(tile):
	var row = rows.find(tile.left(1))
	for col in range(6):
		if (solution[col][row] == tile): return [col, row]
	return [-1,-1]
