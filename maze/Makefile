all: build

clean:
	rm -rf *.obj maze.gbc

build: maze.obj
	rgblink -t -o maze.gbc maze.obj
	rgbfix -v -c -p 0 -t "MazeGen" maze.gbc

maze.obj: maze.asm
	rgbasm -o maze.obj maze.asm
