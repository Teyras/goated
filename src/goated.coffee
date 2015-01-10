G = window.Goated ?= {}

class G.Editor
	constructor: (@element, options) ->
		{@blocks, @formatters} = options

		@element.hide()
		@makeContainer()
		@activeConfig = null
		@blockObjects = []
		@deletedBlocks = []
		
		for item in JSON.parse(@element.val() or '[]')
			for block in @blocks
				if block.type == item.type
					@addBlock new block(this, item.data)
					break
		
		@element.closest('form').on 'submit', =>
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
						.append(" #{block.prototype.title}")
						.on 'click', (e) =>
							e.preventDefault()
							@addBlock new block(this)
				)
			)
		
		$('<div class="btn-group addBlock">')
			.append(
				$('<button type="button" data-toggle="dropdown">')
					.attr('class', 'dropdown-toggle btn btn-default')
					.html('<span class="add-block"></span> Add block')
			).append(blockMenu)
			.appendTo @controls
		
		container.insertAfter @element
	
	openConfig: (block) ->
		@closeConfig()
		
		config = block.getConfig()
		@activeConfig =
			block: block
			config: config
			element: $('<div class="config-container">')
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
		
		if block.getConfig?
			configBtn = $ '<span class="config">'
			
			configBtn.on 'click', (e) =>
				e.preventDefault()
				
				if @activeConfig? and @activeConfig.block is block
					@closeConfig()
				else
					@openConfig block
			
			controls.prepend configBtn
	
	serialize: ->
		result = for block in @blockObjects when block not in @deletedBlocks
			type: block.constructor.type
			data: block.getContent()
		
		@element.text JSON.stringify(result)
	
	srcToHtml: (src) ->
		for formatter in @formatters
			src = formatter.srcToHtml(src)
		return src.replace(/\n/g, '<br>')
	
	htmlToSrc: (html) ->
		for formatter in @formatters
			html = formatter.htmlToSrc(html)
		return html.replace(/<br ?\/?>/g, '\n')
	
	clearHtml: (html) ->
		return html.replace(/<br ?\/?>/g, '')


class G.BaseBlock
	title: 'Untitled block'
	icon: 'block-untitled'
	element: $ '<div>'
	getContent: ->

class G.BaseFormatter
	@title: 'Untitled formatter'
	@icon: 'format-untitled'
	@srcToHtml: (src) -> src
	@htmlToSrc: (html) -> html
	@apply: ->

class G.FormatBar
	constructor: (@editor, formatters) ->
		arrow = $('<div class="arrow">')
			.css left: '50%'
		content = $ '<div class="popover-content">'
		
		for formatter in formatters then do (formatter) ->
			content.append($("<a class='#{formatter.icon}' href='#'>")
				.on 'click', (e) ->
					e.preventDefault()
					formatter.apply()
			)
		
		@bar = $('<div class="format-bar popover top">')
			.css(position: 'absolute')
			.append(arrow)
			.append(content)
			.hide()
		
		@element = $('<div>')
			.css(position: 'relative')
			.append(@bar)
			.append(@editor)
		
		@editor.on 'keyup mouseup mousedown', (e) =>
			selection = window.getSelection?()
			if selection.toString?()
				sBound = selection.getRangeAt(0).getBoundingClientRect()
				cBound = @element[0].getBoundingClientRect()
				@bar.css(
					top: sBound.top - @bar.height() - cBound.top
					left: (sBound.left + sBound.right) / 2 - @bar.width() / 2 - cBound.left
				).show()
			else
				@bar.hide()
	hide: ->
		@bar.hide()

$.fn.goated = (options) ->
	@each ->
		new G.Editor $(this), options
		return this
