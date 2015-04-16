
$ = (el_id) ->
	document.getElementById(el_id)


each = (list, cb) ->
	for el in list
		cb.call(this, el)
	