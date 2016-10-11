G = window.Goated ?= {}
G.locale ?= {}

G.locale.en =
	addBlock: 'Add block'
	unknownBlock: 'Unknown block'
	format:
		bold: "Bold"
		italic: "Italic"
		link: "Link"
		linkPlaceholder: "Enter or paste the address..."
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
		'goated-file':
			title: 'File'
			config:
				title: 'Title'
				url: 'File address'
				upload: 'Drag and drop a file to upload it'
		'goated-album':
			title: 'Image album'
			config:
				upload: 'Drag and drop files to upload them'
				title: 'Title'
