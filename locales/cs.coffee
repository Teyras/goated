G = window.Goated ?= {}
G.locale ?= {}

G.locale.cs =
	addBlock: 'Přidat blok'
	unknownBlock: 'Neznámý blok'
	blocks:
		'goated-text':
			title: 'Text'
			placeholder: 'Text'
		'goated-heading':
			title: 'Nadpis'
			placeholder: 'Nadpis'
			config:
				level: 'Úroveň'
		'goated-list':
			title: 'Seznam'
			config:
				ordered: 'Číslovaný seznam'
		'goated-image':
			title: 'Obrázek'
			config:
				align: 'Umístění'
				alignLeft: 'Obtékat zprava'
				alignBlock: 'Samostatně'
				alignRight: 'Obtékat zleva'
				title: 'Titulek'
				url: 'Adresa obrázku (zmenšený)'
				full: 'Adresa obrázku (plná velikost)'
				sameWindow: 'Otevírat zvětšený obrázek přímo'
				upload: 'Pokud chcete nahrát soubor, přetáhněte ho sem'
		'goated-album':
			title: 'Album obrázků'
			config:
				upload: 'Pokud chcete nahrát soubory, přetáhněte je sem'
