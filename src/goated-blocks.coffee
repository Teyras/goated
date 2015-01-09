G = window.Goated ?= {}

class G.TextBlock extends G.BaseBlock
	constructor: (@parent, data = {}) ->
		data.content ?= 'Text'
		content = @parent.srcToHtml(data.content)
		
		@editor = $ '<div contenteditable="true">'
			.html(content)
		
		bar = new G.FormatBar(@editor, @parent.formatters)
		@element = bar.element
	@type: 'goated-text'
	title: 'Text'
	icon: 'block-text'
	getContent: ->
		content: @parent.htmlToSrc(@editor.html())

class G.HeadingBlock extends G.BaseBlock
	constructor: (@parent, data = {}) ->
		data.content ?= 'Text'
		@level = data.level ?= 1
		@element = $("<h#{@level} contenteditable='true'>").html(data.content)
	@type: 'goated-heading'
	title: 'Heading'
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
			.append($('<label>').text('Level'))
			.append(
				$('<div class="config-control">')
					.append select
			)
	saveConfig: (config) ->
		@level = config.find('select').val()
		@element = $("<h#{@level} contenteditable='true'>").html(@element.html())

class G.ListBlock extends G.BaseBlock
	constructor: (@parent, data = {}) ->
		content = data.content ?= ['']
		@ordered = data.ordered ?= no
		@element = if @ordered then $('<ol>') else $('<ul>')
		for item in content
			@element.append(@makeItem(@parent.srcToHtml(item)))
	@type: 'goated-list'
	title: 'List'
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
		
		return (new G.FormatBar(item, @parent.formatters)).element
	getConfig: ->
		checkbox = $('<input type="checkbox">').prop('checked', @ordered)
		
		$('<div class="config-item">')
			.append($('<label>').text('Ordered'))
			.append(
				$('<div class="config-control">')
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
		@align = data.align ?= 'block'
		@src = data.content ?= ''
		@element = $('<img>')
		@element.attr('src', @src)
	@type: 'goated-image'
	title: 'Image'
	icon: 'block-image'
	getContent: ->
		align: @align
		content: @src
	getConfig: ->
		$('<div>')

