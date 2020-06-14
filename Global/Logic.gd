extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var Cell = preload("res://Scripts/Cell.gd")
var Clue = preload("res://Scripts/Clue.gd")
var selected = []
var field = []
var solution = []
const tiles = ["1", "2", "3", "4", "5", "6"]
const rows = ["A", "B", "C", "D", "E", "F"]
var ingame = []
var rng = RandomNumberGenerator.new()

var clues = {}
# Called when the node enters the scene tree for the first time.
func _ready():
	seed("TestLevel".hash())
	for col in range(6):
		field.append([])
		for row in range(6):
			field[col].append(_rowTiles(row))			
	createLvl()

func createLvl():
	for col in range(6):
		solution.append([])
		selected.append([])
	for row in range(6):
		var ans = _rowTiles(row)
		ans.shuffle()
		for col in range(6):
			solution[col].append(ans[col])
			ingame.append(ans[col])
			selected[col].append(null)
	#print(_findInSolution("B6"))
	#print(solution[1])
	_createClues()
	_trySolve()

func _createClues():
	for type in GL.CLUETYPE.values():
		clues[type] = []
	print(clues)	
	

func _trySolve():
	var changed = true
	while (changed == true):
		changed = false
		if (_checkLast() == true): changed = true
		if (_checkOnly() == true): changed = true
		if (_checkClues() == true): changed = true
	if (_isSolved()): return
	_createClue()
	#_trySolve()
	
func _checkClues():
	print("check clues")
	return false

func _createClue():
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
		clue.tile3 = arr[3]
	elif clue.type == GL.CLUETYPE.SELECTED:
		clue.tile1 = tile
	print(clue.type)
	clues[clue.type].append(clue)
		
	
func _getClueType():
	var num = rng.randi_range(0, 99)
	if (num < 15): return GL.CLUETYPE.NEAR
	if (num < 30): return GL.CLUETYPE.COLUMN
	if (num < 45): return GL.CLUETYPE.BETWEEN
	if (num < 60): return GL.CLUETYPE.TOLEFT
	if (num < 75): return GL.CLUETYPE.NOTBETWEEN
	if (num < 90): return GL.CLUETYPE.NOTCOL
	if (num < 95): return GL.CLUETYPE.NOTNEAR
	return GL.CLUETYPE.SELECTED

func _selectTile(col, row, tile):
	ingame.erase(tile)
	selected[col][row] = tile
	field[col][row] = []
	for col in range (6):
		for row in range(6):
			field[col][row].erase(tile)
	
func _checkLast():
	print("check last")
	var changed = false
	for col in range (6):
		for row in range(6):
			if field[col][row].size() == 1:
				_selectTile(col, row, field[col][row][0])
				changed = true
	return changed
	
func _checkOnly():
	print("check only")
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

func _findInSolution(tile):
	var row = rows.find(tile.left(1))
	for col in range(6):
		if (solution[col][row] == tile): return [col, row]
	return [-1,-1]
