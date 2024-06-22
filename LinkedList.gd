## Double Linked Lists #########################################################

extends Node


## LIST ########################################################################

class List extends Object:
	## Private: ****************************************************************
	static var _list_count : int = 0
	static var _list_links : Array[Link] = []
	static var _trash : Link = null
	
	var first : Link = null
	var last : Link = null
	
	
	## Read only: **************************************************************
	var count : int = 0
	
	
	## Public: *****************************************************************
	## Get list size -----------------------------------------------------------
	# return:	<int> 	Amount of links in the list
	func size() -> int:
		return count
	
	
	## Add a member to the head of the list ------------------------------------
	# Parameters:
	#	_object		<Variant>	the object to be added
	# return:	<int>	newly created link id
	#			-1		on error
	func push_front( 
		_object : Variant 
	) -> int:
		if OS.is_debug_build():
			if _object == null:
				push_warning( "null object in List.push_front\n list: ", self )
				return -1
		
		var _link : Link = _new_list_object( _object )
		if first != null:
			_link.prev = null
			_link.next = first
			first.prev = _link
			first = _link
		else:
			first = _link
			last = _link
		
		count += 1
		return _link.id
	
	
	## Add a member to the tail of the list ------------------------------------
	# Parameters:
	#	_object		<Variant>	the object to be added
	# return:	<int>	newly created link id
	#			-1		on error
	func push_back( 
		_object : Variant
	) -> int:
		if OS.is_debug_build():
			if _object == null:
				push_warning( "null object in List.push_back\n list: ", self )
				return -1
		
		var _link : Link = _new_list_object( _object )
		if last != null:
			last.next = _link
			_link.prev = last
			_link.next = null
			last = _link
		else:
			first = _link
			last = _link
		
		count += 1
		return _link.id
	
	
	## Add a member to the list sorted by a function call ----------------------
	# Parameters:
	#	_object				<Variant>	the object to be added
	#	_sorting_method		<Callable>	the sorting method
	#		signature:
	# 			func my_sorting_method( _obj0, _obj1 ) -> bool:
	#				if _obj1 < _obj0:	return true
	#				else:				return false
	# return:	<int>	newly created link id
	#			-1		on error
	func push_sorted( 
		_object : Variant,
		_sorting_method : Callable 
	) -> int:
		if OS.is_debug_build():
			if _object == null:
				push_warning( "null object in List.push_sorted\n list: ", self )
				return -1
		
		var _link : Link = _new_list_object( _object )
		
		if first == null:
			first = _link
			last = _link
			_link.prev = null
			_link.next = null
			count = 1
			return _link.id
		
		var _current : Link = first
		while _current != null:
			if _sorting_method.call( _current.object, _link.object ):
				_link.prev = _current.prev
				if _current.prev != null:
					_current.prev.next = _link
				_link.next = _current
				_current.prev = _link
				if _current == first:
					first = _link
				count += 1
				return _link.id
			
			_current = _current.next
		
		last.next = _link
		_link.prev = last
		_link.next = null
		last = _link
		
		count += 1
		return _link.id
	
	
	## Sustract the first member of the list -----------------------------------
	# return:	<Variant>	the first member of the list
	#			null		if empty
	func pop_front() -> Variant:
		if first == null:
			return null
		
		var _link : Link = first
		first = first.next
		if first != null:
			first.prev = null
		if last == _link:
			last = null
		
		count -= 1
		var _object : Variant = _link.object
		_to_trash( _link )
		return _object
	
	
	## Sustract the last member of the list ------------------------------------
	# return:	<Variant>	the last member of the list
	#			null		if empty
	func pop_back() -> Variant:
		if last == null:
			return null
		
		var _link : Link = last
		last = last.prev
		if last != null:
			last.next = null
		if first == _link:
			first = null
		
		count -=1
		var _object : Variant = _link.object
		_to_trash( _link )
		return _object
	
	
	## Sustract the member of the list pointed by a link id --------------------
	# Parameters:
	#	_id		<int>		the id of a link contained by the list
	# return:	<Variant>	the member of the list
	#			null		on error or empty
	func pop_by_id(
		_id : int
	) -> Variant:
		if first == null:
			return null
		
		if OS.is_debug_build():
			if _id >= List._list_links.size() or _id < 0:
				push_error( "link id out of range in List.pop_by_id\n list: ", self, "\n id: ", _id )
				return null
		
		var _link : Link = List._list_links[ _id ]
		
		if OS.is_debug_build():
			if _link.owner != self:
				push_warning( "Link is not owned by list in List.pop_by_id\n list: ", self, "\n id: ", _id )
				return null
		
		if first == _link:
			first = _link.next
			if first == null:
				last = null
			else:
				first.prev = null
			
		elif last == _link:
			last = _link.prev
			last.next = null
			
		else:
			_link.prev.next = _link.next
			_link.next.prev = _link.prev
		
		count -= 1
		var _object = _link.object
		_to_trash( _link )
		return _object
	
	
	## Iterate through the list from start to end ------------------------------
	# Parameters:
	#	_iterator	<int>	a link id in the list
	#				-1		start from the head of the list
	# return:		<int>	next link id
	#						or the id of the first link of the list
	#				-1		when the list is empty or last iteration was reached
	func iterate( _iterator : int = -1 ) -> int:
		if first == null:
			return -1
		if _iterator < 0:
			return first.id
		else:
			var _link : Link = List._list_links[ _iterator ]
			if _link.next != null:
				return _link.next.id
			else:
				return -1
	
	
	## Iterate through the list from end to start ------------------------------
	# Parameters:
	#	_iterator	<int>	a link id in the list
	#				-1		start from the tail of the list
	# return:		<int>	previous link id
	#						or the id of the last link of the list
	#				-1		when the list is empty or last iteration was reached
	func iterate_back( _iterator : int = -1 ) -> int:
		if last == null:
			return -1
		if _iterator < 0:
			return last.id
		else:
			var _link : Link = List._list_links[ _iterator ]
			if _link.prev != null:
				return _link.prev.id
			else:
				return -1
	
	
	## Get the object pointed by a link id -------------------------------------
	# Parameter:
	#	_id		<int>		the id of a link
	# return:	<Variant>	the object pointed by the link id
	#			null		if empty
	func get_object_by_id( _id : int ) -> Variant:
		return List._list_links[ _id ].object
	
	
	
	
	## Private: ****************************************************************
	
	func _init():
		List._list_count += 1
	
	
	func _new_list_object(
		_object : Variant
	) -> Link:
		var _list_object : Link
		if List._trash:
			_list_object = List._trash
			List._trash = _list_object.next
			_list_object.object = _object
			_list_object.prev = null
			_list_object.next = null
			_list_object.owner = self
			
			return _list_object
		
		_list_object = Link.new()
		_list_object.object = _object
		_list_object.prev = null
		_list_object.next = null
		_list_object.id = List._list_links.size()
		List._list_links.push_back( _list_object )
		_list_object.owner = self
		
		return _list_object
	
	
	func _to_trash( _link : Link ):
		_link.owner = null
		_link.object = null
		_link.prev = null
		_link.next = List._trash
		List._trash = _link
	
	
	func _notification( _notification_id ):
		match _notification_id:
			NOTIFICATION_PREDELETE:
				List._list_count -= 1
				if List._list_count > 0:
					# fast
					#if first != null:
						#last.next = List._trash
						#List._trash = first
					# clean
					var _link = first
					while _link != null:
						var _l = _link
						_link = _l.next
						_to_trash( _l )
				else:
					for _l in List._list_links:
						_l.free()
					List._trash = null
					List._list_links.clear()



## LINK ########################################################################
## Private: ********************************************************************

class Link extends Object:
	var id : int = -1
	var owner : List = null
	var object : Variant = null
	var prev : Link = null
	var next : Link = null



## HELPERS #####################################################################
## Public: *********************************************************************

## Create a new list -----------------------------------------------------------
# return	<List>	newly created list
func create() -> List:
	return List.new()


## Remove a list ---------------------------------------------------------------
# Parameters:
# 	_list	<List>	a list to remove
func remove( _list : List ):
	if OS.is_debug_build():
		if _list == null:
			push_warning( "null list on LinkedList.remove_list" )
			return
	_list.free()


## Print a list to console -----------------------------------------------------
# Parameters:
# 	_list	<List>	a list to print
func print_list( _list : List ):
	print( "List: ", _list )
	print( " size: ", _list.count )
	var _link : Link = _list.first
	while _link != null:
		var _object = _link.object
		if _object.has_method( "print_to_console" ):
			_object.print_to_console()
		else:
			print( "  ", _link.id, ": ", _object )
		_link = _link.next
	
