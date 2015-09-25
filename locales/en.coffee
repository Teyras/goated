G = window.Goated ?= {}
G.locale ?= {}

G.locale.cs =
	addBlock: 'Add block'
	unknownBlock: 'Unknown block'
	blocks:
		'goated-text':
			title: 'Text'
			placeholder: 'Text'
		'goated-heading':
			title: 'Heading'
			placeholder: 'Heading'
			config:
				level: 'Level'
		'goated-list':
			title: 'List'
			config:
				ordered: 'Ordered list'
		'goated-image':
			title: 'Image'
			config:
				align: 'Placement'
				alignLeft: 'Float left'
				alignBlock: 'Standalone'
				alignRight: 'Float right'
				title: 'Title'
				url: 'Thumbnail address'
				full: 'Full image address'
				sameWindow: 'Open the full image directly'
				upload: 'Drag and drop a file to upload it'
