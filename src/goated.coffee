G = window.Goated ?= {}
G.locale ?= {}

class G.Editor
	constructor: (@element, options) ->
		{@blocks, @urls, @locale} = options
		@urls ?= {}
		@locale ?= 'en'

		@tr = G.Translator G.locale[@locale]
		
		@element.hide()
		@makeContainer()
		@activeConfig = null
		@blockObjects = []
		@deletedBlocks = []
		
		defaultBlocks =
		try
			JSON.parse(@element.val())
		catch error
			[{
				type: 'goated-text'
				data:
					content: @element.val()
			}]
		
		for item in defaultBlocks
			found = false
			
			for block in @blocks
				if block.type == item.type
					@addBlock new block(this, item.data)
					found = true
					break
			
			if not found
				@addBlock new G.UnknownBlock(this, item.type, item.data, @tr 'unknownBlock')
		
		@element.closest('form').on 'submit', =>
			@closeConfig()
			@serialize()

		@element.closest('form').on 'goated.submit', =>
			@closeConfig()
			@serialize()

	makeContainer: ->
		container = $('<div class="goated-container">')
		
		@blockList = $('<div class="goated-blocks">')
			.appendTo container
		
		@blockList.sortable
			handle: '.move'
			placeholder: 'goated-placeholder'
			start: => @closeConfig()
		
		@controls = $('<div class="goated-controls">')
			.appendTo container
		
		blockMenu = $ '<ul class="blockMenu dropdown-menu" role="menu">'
		
		for block in @blocks then do (block) =>
			blockMenu.append(
				$('<li>').append(
					$('<a href="#">')
						.append($ "<span class='#{block.prototype.icon}'></span>")
						.append(" " + @tr "blocks.#{block.type}.title")
						.on 'click', (e) =>
							e.preventDefault()
							@addBlock new block(this)
				)
			)
		
		$('<div class="btn-group addBlock">')
			.append(
				$('<button type="button" data-toggle="dropdown">')
					.attr('class', 'dropdown-toggle btn btn-default')
					.append($('<span class="add-block"></span>'))
					.append(" " + @tr 'addBlock')
			).append(blockMenu)
			.appendTo @controls
		
		container.insertAfter @element
	
	openConfig: (block) ->
		@closeConfig()
		
		config = block.getConfig()
		@activeConfig =
			block: block
			config: config
			element: $('<div class="goated-config-container">')
				.append config
		
		block.element.replaceWith @activeConfig.element
	
	closeConfig: () ->
		if !@activeConfig? then return
		
		block = @activeConfig.block
		block.saveConfig?(@activeConfig.config)
		@activeConfig.element.replaceWith block.element
		@activeConfig = null
	
	addBlock: (block) ->
		@blockObjects.push block
		
		content = $ '<div class="content">'
		controls = $('<div class="controls">')
			.append($('<span class="delete">')
				.on 'click', (e) =>
					e.preventDefault()
					$(e.target).closest('.goated-block').remove()
					@deletedBlocks.push block
			)
			.append($ '<span class="move">')
		
		element = $('<div class="goated-block">')
			.append(content.append(block.element))
			.append(controls)
			.appendTo(@blockList)

		block.element.trigger("goated.editorinsert", {})
		
		if block.getConfig?
			configBtn = $ '<span class="config">'
			
			configBtn.on 'click', (e) =>
				e.preventDefault()
				
				if @activeConfig? and @activeConfig.block is block
					@closeConfig()
				else
					@openConfig block
			
			controls.prepend configBtn

	makeRichTextEditor: (target, placeholder, inline = false) ->
		if inline
			$(target).attr "data-disable-return", true

		new MediumEditor $(target).get(0),
			disableDoubleReturn: true
			disableExtraSpaces: true
			placeholder:
				text: placeholder
			toolbar:
				buttons: [
					{name: "bold", aria: @tr "format.bold"},
					{name: "italic", aria: @tr "format.italic"},
					{name: "anchor", aria: @tr "format.link"}
				]
			anchor:
				placeholderText: @tr "format.linkPlaceholder"

	getRichTextEditorContent: (target) ->
		$(target).closest(".goated-block").find("[contenteditable=true]")

	serialize: ->
		@blockObjects.sort (a, b) =>
			items = @blockList.find '.goated-block'
			first = a.element.closest '.goated-block'
			second = b.element.closest '.goated-block'
			return items.index(first) - items.index(second)
		
		result = for block in @blockObjects when block not in @deletedBlocks
			type: block.getType()
			data: block.getContent()
		
		@element.text JSON.stringify(result)
	
	srcToHtml: (src, paragraphs = false) ->
		# Hide escaped asterisks
		src = src.replace /\u0001/g, ""
		src = src.replace /\\\*/g, "\u0001"

		# Link style BC
		src = src.replace(/"(.*)":\[(.*?)\]/g, (m, text, href) -> "[#{text}](#{href})")

		# Compile to HTML
		renderer = new marked.Renderer()
		renderer.strong = (text) -> "<b>#{text}</b>"
		renderer.em = (text) -> "<i>#{text}</i>"
		src = marked(src, renderer: renderer, breaks: true)

		# Show escaped asterisks
		src = src.replace /\u0001/g, "*"
		src = src.replace /^\s+|\s+$/g, ''

		if not paragraphs
			tmp = $("<div>").html(src)
			tmp.find("p").contents().unwrap()
			src = tmp.html()

		return src

	htmlToSrc: (element) ->
		# Remove inline styles and scripts
		element.find('style, script').remove()

		# Remove empty tags
		for node in element.find('p, i, b, a') when /^\s*$/.test $(node).text()
			$(node).remove()

		# Strip all HTML tags that we don't want to keep
		for node in element.find(':not(b, i, a, p br, p)')
			content = $(node).contents()

			if content.length > 0
				content.unwrap()
			else
				$(node).remove()

		# Remove unwanted attributes
		for node in element.find('b, i, a, p, br')
			for attr in node.attributes
				if $(node).is("a") and attr.name.toLowerCase() == "href"
					continue
				$(node).removeAttr(attr.name)

		src = element.html()

		# Remove useless whitespace
		src = src.replace(/\s+/g, " ")

		# Hide literal asterisks and underscores
		src = src.replace /\u0011/g, ""
		src = src.replace /\u0012/g, ""
		src = src.replace(/\*/g, "\u0011")
		src = src.replace(/_/g, "\u0012")

		# Convert manual line breaks to newlines
		src = src.replace(/<br\s*\/?>/g, "\n").replace(/\n+/g, "\n")

		# Convert formatting tags
		src = src.replace(/<b\s*>/gi, '**').replace(/<\/b>/gi, '**')
		src = src.replace(/<i\s*>/gi, '_').replace(/<\/i>/gi, '_')
		src = src.replace /<a\s*href=["'](.*?)["']\s*>(.*?)<\/a>/gi, (m, href, text) ->
			"[#{text}](#{href.replace("\n", " ").trim()})"

		# Convert paragraphs to double newlines
		src = src.replace(/<p\s*>/gi, "")
		src = src.replace(/<\/\s*p\s*>/gi, "\n\n")

		# Squeeze whitespace out of tags
		src = @tightenTags(src)

		# Strip whitespace from the edges
		src = src.replace(/^\s+|\s+$/g, '')

		# Show asterisks and escape them
		src = src.replace /\u0011/g, "\\*"

		# Replace underscores with asterisks and show real underscores
		src = src.replace /_/g, "*"
		src = src.replace /\u0012/g, "_"

	tightenTags: (text) ->
		console.log JSON.stringify(text)
		esc = (str) -> str.replace(/[\-\[\]\/\{\}\(\)\*\+\?\.\\\^\$\|]/g, "\\$&")

		tags = [
			["**", "**"],
			['_', '_'],
			["[", "]"]
		]

		for pair in tags
			text = text.replace new RegExp(esc(pair[0]) + '([\\s\\S]*?)' + esc(pair[1]), 'g'), (m, content) =>
				pair[0] + (@tightenTags content) + pair[1]

		for pair in tags
			text = text.replace new RegExp(esc(pair[0]) + "([\\s\\S]*?)" + esc(pair[1]), 'g'), (m, content) =>
				match = content.match /^(\s*)(\S?|\S[\s\S]*\S)(\s*)$/
				return match[1] + pair[0] + match[2] + pair[1] + match[3]

		return text

G.Translator = (dictionary) ->
	dictionary ?= {}

	return (message) ->
		data = dictionary

		for part in message.split('.')
			if data[part]?
				data = data[part]

		if data? and typeof data != 'object'
			return data
		else
			return message

class G.BaseBlock
	title: 'Untitled block'
	icon: 'block-untitled'
	element: $ '<div>'
	getType: -> @constructor.type
	getContent: ->
	constructor: (parent, data = {}) ->
		@tr = G.Translator G.locale[parent.locale]?.blocks[@constructor.type]

$.fn.goated = (options) ->
	@each ->
		new G.Editor $(this), options
		return this
