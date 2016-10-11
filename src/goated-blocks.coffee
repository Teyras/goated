G = window.Goated ?= {}

class G.UnknownBlock extends G.BaseBlock
	constructor: (@parent, @blockType, @data = {}, title) ->
		super @parent, @data
		@element.html title
	getType: -> @blockType
	getContent: -> @data

class G.TextBlock extends G.BaseBlock
	constructor: (@parent, data = {}) ->
		super @parent, data

		data.content ?= ""
		content = @parent.srcToHtml(data.content, true)

		@editor = $('<div>')

		@editor.on "goated.editorinsert", =>
			@parent.makeRichTextEditor(@editor, @tr 'placeholder')

		@editor.html(content)

		@element = @editor
	@type: 'goated-text'
	icon: 'block-text'
	getContent: ->
		content: @parent.htmlToSrc(@parent.getRichTextEditorContent(@editor))

class G.HeadingBlock extends G.BaseBlock
	constructor: (@parent, data = {}) ->
		super @parent, data
		
		data.content ?= @tr 'placeholder'
		@level = data.level ?= 1
		@element = $("<h#{@level} contenteditable='true'>").text(data.content)
	@type: 'goated-heading'
	icon: 'block-heading'
	getContent: ->
		level: @level
		content: @element.text()
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
		@element = $("<h#{@level} contenteditable='true'>").text(@element.text())

class G.ListBlock extends G.BaseBlock
	constructor: (@parent, data = {}) ->
		super @parent, data
		
		content = data.content ?= ['']
		@ordered = data.ordered ?= no
		@element = if @ordered then $('<ol>') else $('<ul>')
		for item in content
			@element.append(@makeItem(@parent.srcToHtml(item)))

		@element.on "goated.editorinsert", =>
			for item in @element.children()
				$(item).trigger("goated-list.itemattach", {})
	@type: 'goated-list'
	icon: 'block-list'
	getContent: ->
		ordered: @ordered
		content: for item in @element.find('li') when $(item).html()
			@parent.htmlToSrc($(item))
	makeItem: (content) ->
		item = $('<li>').html(content)

		item.on "goated-list.itemattach", =>
			medium = @parent.makeRichTextEditor(item, "", true)

			medium.subscribe 'editableKeydown', (e) =>
				list = if @ordered then 'ol' else 'ul'

				if e.keyCode == 13 # Enter
					e.preventDefault()
					if $(e.target).html()
						item = @makeItem('')
						item.insertAfter $(e.target).closest('li')
						item.trigger("goated-list.itemattach", {})
						item.focus()
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
							prevMedium = MediumEditor.getEditorFromElement(prev.get(0))
							prevMedium.selectAllContents()
							MediumEditor.selection.clearSelection(document, false)
							$(e.target).remove()
		###
			.on 'keydown', (e) =>
				list = if @ordered then 'ol' else 'ul'
				
				if e.keyCode == 13 # Enter
					e.preventDefault()
					if $(e.target).html()
						item = @makeItem('')
						item.insertAfter $(e.target).closest('li')
						item.focus()
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
		###
		
		return item
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
		@element.contents().detach().appendTo(list)
		@element.remove()

		@element = list


class G.ImageBlock extends G.BaseBlock
	constructor: (@parent, data = {}) ->
		super @parent, data
		
		@align = data.align ?= 'block'
		@title = data.title ?= ''
		@src = data.src ?= ''
		@full = data.full ?= ''
		@sameWindow = data.sameWindow ?= false
		
		@element = $('<img>')
		@setupElement()
	@type: 'goated-image'
	icon: 'block-image'
	getContent: ->
		align: @align
		title: @title
		src: @src
		full: @full
		sameWindow: @sameWindow
	getConfig: ->
		select = $('<select>')
			.append($('<option name="block">').text(@tr 'config.alignBlock'))
			.append($('<option name="left">').text(@tr 'config.alignLeft'))
			.append($('<option name="right">').text(@tr 'config.alignRight'))
		select.val select.find("option[name='#{@align}']").text()

		title = $('<input type="text" name="title">')
			.val @title

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
			.append($('<label>').text(@tr 'config.title'))
			.append($('<div class="config-control">').append title)
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
		@title = config.find('input[name="title"]').val()
		@src = config.find('input[name="src"]').val()
		@full = config.find('input[name="full"]').val()
		@sameWindow = config.find('input[name="sameWindow"]').prop('checked')
		
		@setupElement()
	setupElement: ->
		@element.attr('src', @src)
		
		if not @src
			@element.hide()
		else
			@element.show()

class G.FileBlock extends G.BaseBlock
	constructor: (@parent, data = {}) ->
		super @parent, data

		@title = data.title ?= ''
		@url = data.url ?= ''

		@element = $('<span>')
		@setupElement()
	@type: 'goated-file'
	icon: 'block-file'
	getContent: ->
		title: @title
		url: @url
	getConfig: ->
		title = $('<input type="text" name="title">')
			.val @title

		url = $('<input type="text" name="url">')
			.val @url

		config = $('<div>').append($('<div class="config-item">')
			.append($('<label>').text(@tr 'config.title'))
			.append($('<div class="config-control">').append title)
		).append($('<div class="config-item">')
			.append($('<label>').text(@tr 'config.url'))
			.append($('<div class="config-control">').append url)
		)

		if @parent.urls.fileUpload
			upload = $('<div>')
				.attr(class: 'upload-area')
				.html(@tr 'config.upload')
			upload.fileupload(
				url: @parent.urls.fileUpload
				dataType: 'json'
				autoUpload: true
				dropZone: upload
				disableImagePreview: true
			).bind('fileuploaddone', (e, data) =>
				config.find('input[name="url"]').val(data.result.url)
				@parent.closeConfig()
			)

			config.append upload

		return config
	saveConfig: (config) ->
		@title = config.find('input[name="title"]').val()
		@url = config.find('input[name="url"]').val()

		@setupElement()
	setupElement: ->
		if @title
			@element.html("#{@title} (#{@url})")
		else
			@element.html(@url)

class G.AlbumBlock extends G.BaseBlock
	constructor: (@parent, data = {}) ->
		super @parent, data
		@element = $ '<div class="goated-thumbnails">'
		@images = data.images ?= new Array()
		@setupElement(data)

	setupElement: ->
		@element.empty()

		for image in @images
			thumbnail = @addImage @element, image.url, image.full
			caption = $ '<div class="goated-thumbnails-title">'
			caption.text image.title
			thumbnail.append caption

	@type: 'goated-album'
	icon: 'block-album'

	getContent: ->
		images: @images

	getConfig: ->
		config = $ '<div>'
		thumbnails =  $ '<div class="goated-thumbnails">'
		thumbnails.sortable
			placeholder: 'goated-placeholder'

		for image in @images
			thumbnail = @addImage thumbnails, image.url, image.full
			caption = $ '<div class="goated-thumbnails-title-edit">'
			input = $ "<input>"
			input.attr 'type', 'text'
			input.attr 'placeholder', "#{@tr 'config.title'}"
			input.attr 'name', 'title'

			if image.title
				input.val(image.title)

			caption.append input
			thumbnail.append caption

		config.append thumbnails

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
				@addImage thumbnails, data.result.thumbnail, data.result.full
			)

			config.append upload

		return config

	saveConfig: (config) ->
		@images = new Array()

		for image in $(config).find('.goated-thumbnails img')
			@images.push
				url: $(image).attr 'src'
				full: $(image).data 'full'
				title: $(image).closest('.goated-thumbnails-item').find('input[name="title"]').val()

		@setupElement()

	addImage: (element, thumbnailUrl, imageUrl) ->
		image = $ '<img>'
		image.attr 'src', thumbnailUrl
		image.data 'full', imageUrl

		item = $ '<div class="goated-thumbnails-item">'
		item.append image

		container = $ '<div class="goated-thumbnails-container">'
		container.append item

		element.append container
		return item
