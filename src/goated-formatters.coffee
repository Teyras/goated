G = window.Goated ?= {}

class G.BoldFormatter extends G.BaseFormatter
	@icon: 'bold'
	@srcToHtml: (src) ->
		src.replace /\*\*([^*]+)\*\*/gm, (match, arg1) ->
			"<b>#{arg1}</b>"
	@htmlToSrc: (html) ->
		html.replace(/<b>/gim, '**').replace(/<\/b>/gim, '**')
	@apply: ->
		document.execCommand('bold', false, false)

class G.ItalicFormatter extends G.BaseFormatter
	@icon: 'italic'
	@srcToHtml: (src) ->
		src.replace /\*([^*]+)\*/gm, (match, arg1) ->
			"<i>#{arg1}</i>"
	@htmlToSrc: (html) ->
		html.replace(/<i>/gim, '*').replace(/<\/i>/gim, '*')
	@apply: ->
		document.execCommand('italic', false, false)

class G.LinkFormatter extends G.BaseFormatter
	@icon: 'link'
	@srcToHtml: (src) ->
		src.replace /"(.*?)":\[(.*?)\]/g, (m, text, href) ->
			"<a href='#{href}'>#{text}</a>"
	@htmlToSrc: (html) ->
		html.replace /<a.*?href=[""'](.*?)[""'].*?>(.*?)<\/a>/gim, (m, href, text) ->
			"\"#{text}\":[#{href}]"
	@apply: ->
		href = window.prompt('Link')
		if href and href.length > 0
			document.execCommand('createLink', false, href)

class G.UnlinkFormatter extends G.BaseFormatter
	@icon: 'unlink'
	@apply: ->
		document.execCommand('unlink', false, false)
