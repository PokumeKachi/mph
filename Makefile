all:
	luajit src/parser.lua > build/mph.html
	pandoc build/mph.html --embed-resources --standalone --css=style.css --pdf-engine=weasyprint -o build/mph.pdf

git:
	git commit -a
	git push
	# pandoc mph-pdf.md \
	# 	-f html -t pdf \
	# 	-o build/mph.pdf \
	# 	--pdf-engine=weasyprint \
	# 	-V 'mainfont:NotoSerif-Regular.ttf' \
	# 	-V 'mainfontoptions:BoldFont=NotoSerif-Bold.ttf, ItalicFont=NotoSerif-Italic.ttf, BoldItalicFont=NotoSerif-BoldItalic.ttf' \
	# 	-V geometry:margin=1cm
