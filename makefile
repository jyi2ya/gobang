posix:
	gcc -Wall -Werror -Wshadow -g -fsanitize=address -O0 -pedantic gobang.cpp -o gobang

win:
	/mnt/d/opt/tcc64/tcc.exe gobang.c -o gobang.exe

ansi:
	gcc -Wall -Werror -Wshadow -g -fsanitize=address -O0 -pedantic gobang.cpp -o gobang

doc:
	cd doc
	pandoc --metadata title='五子棋项目设计文档' -s gobang.md -o gobang.html
