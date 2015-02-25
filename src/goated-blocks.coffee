G = window.Goated ?= {}

class G.TextBlock extends G.BaseBlock
	constructor: (@parent, data = {}) ->
		super @parent, data
		
		if !data.content
			data.content = @tr 'placeholder'
		
		content = @parent.srcToHtml(data.content)
		
		@editor = $('<div contenteditable="true">')
			.html(content)
		
		@element = @parent.formatBar.bind @editor
	@type: 'goated-text'
	icon: 'block-text'
	getContent: ->
		content: @parent.htmlToSrc(@editor.html())

class G.HeadingBlock extends G.BaseBlock
	constructor: (@parent, data = {}) ->
		super @parent, data
		
		data.content ?= @tr 'placeholder'
		@level = data.level ?= 1
		@element = $("<h#{@level} contenteditable='true'>").html(data.content)
	@type: 'goated-heading'
	icon: 'block-heading'
	getContent: ->
		level: @level
		content: @parent.clearHtml(@element.html())
	getConfig: ->
		select = $('<select>')
			.append($('<option name=1>').text(1))
			.append($('<option name=2>').text(2))
			.append($('<option name=3>').text(3))
		select.val(@level)
		$('<div class="config-item">')
			.append($('<label>').text(@tr 'config.level'))
			.append(
				$('<div class="config-control">')
					.append select
			)
	saveConfig: (config) ->
		@level = config.find('select').val()
		@element = $("<h#{@level} contenteditable='true'>").html(@element.html())

class G.ListBlock extends G.BaseBlock
	constructor: (@parent, data = {}) ->
		super @parent, data
		
		content = data.content ?= ['']
		@ordered = data.ordered ?= no
		@element = if @ordered then $('<ol>') else $('<ul>')
		for item in content
			@element.append(@makeItem(@parent.srcToHtml(item)))
	@type: 'goated-list'
	icon: 'block-list'
	getContent: ->
		ordered: @ordered
		content: for item in @element.find('li') when $(item).html()
			@parent.htmlToSrc($(item).html())
	makeItem: (content) ->
		item = $('<li contenteditable="true">')
			.html(content)
			.on 'keydown', (e) =>
				list = if @ordered then 'ol' else 'ul'
				
				if e.keyCode == 13 # Enter
					e.preventDefault()
					@makeItem('')
						.insertAfter $(e.target).parent()
						.find('li').focus()
				if e.keyCode == 8 # Backspace
					if not $(e.target).text()
						e.preventDefault()
						
						prev = null
						for item in $(e.target).closest(list).find('li')
							if $(item).is($(e.target))
								break
							prev = $(item)
							
						if prev
							prev.focus()
							$(e.target).remove()
		
		return @parent.formatBar.bind item
	getConfig: ->
		checkbox = $('<input type="checkbox" class="checkbox">').prop('checked', @ordered)
		
		$('<div class="config-item">')
			.append($('<label>').text(@tr 'config.ordered'))
			.append(
				$('<div>')
					.append checkbox
			)
	saveConfig: (config) ->
		@ordered = config.find('input').prop('checked')
		
		list = if @ordered then $('<ol>') else $('<ul>')
		for item in @element.find('li')
			list.append @makeItem($(item).html())
		
		@element = list

class G.ImageBlock extends G.BaseBlock
	constructor: (@parent, data = {}) ->
		super @parent, data
		
		@align = data.align ?= 'block'
		@src = data.src ?= ''
		@full = data.full ?= ''
		@sameWindow = data.sameWindow ?= false
		
		@element = $('<img>')
		@setupElement()
	@type: 'goated-image'
	icon: 'block-image'
	getContent: ->
		align: @align
		src: @src
		full: @full
	getConfig: ->
		select = $('<select>')
			.append($('<option name="block">').text(@tr 'config.alignBlock'))
			.append($('<option name="left">').text(@tr 'config.alignLeft'))
			.append($('<option name="right">').text(@tr 'config.alignRight'))
		select.val select.find("option[name='#{@align}']").text()
		
		src = $('<input type="text" name="src">')
			.val @src
		
		full = $('<input type="text" name="full">')
			.val @full
		
		sameWindow = $('<input type="checkbox" name="sameWindow">')
			.val @sameWindow
		
		config = $('<div>').append($('<div class="config-item">')
			.append($('<label>').text(@tr 'config.align'))
			.append($('<div class="config-control">').append select)
		).append($('<div class="config-item">')
			.append($('<label>').text(@tr 'config.url'))
			.append($('<div class="config-control">').append src)
		).append($('<div class="config-item">')
			.append($('<label>').text(@tr 'config.full'))
			.append($('<div class="config-control">').append full)
		).append($('<div class="config-item">')
			.append($('<label>').text(@tr 'config.sameWindow'))
			.append($('<div class="config-control">').append sameWindow)
		)
		
		if @parent.urls.imageUpload
			upload = $('<div>')
				.attr(class: 'upload-area')
				.html(@tr 'config.upload')
			upload.fileupload(
				url: @parent.urls.imageUpload
				dataType: 'json'
				autoUpload: true
				dropZone: upload
				disableImagePreview: true
			).bind('fileuploaddone', (e, data) =>
				config.find('input[name="src"]').val(data.result.thumbnail)
				config.find('input[name="full"]').val(data.result.full)
				@parent.closeConfig()
			)
			
			config.append upload
		
		return config
	saveConfig: (config) ->
		@align = config.find('select option:selected').attr('name')
		@src = config.find('input[name="src"]').val()
		@full = config.find('input[name="full"]').val()
		
		@setupElement()
	setupElement: ->
		@element.attr('src', @src)
		
		if not @src
			@element.hide()
		else
			@element.show()

