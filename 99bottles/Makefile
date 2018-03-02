all: build

clean:
	rm -rf *.obj 99bottles.gbc

build: 99bottles.obj
	rgblink -t -o 99bottles.gbc 99bottles.obj
	rgbfix -v -c -p 0 -t "99BOBA" 99bottles.gbc

99bottles.obj: 99bottles.asm
	rgbasm -o 99bottles.obj 99bottles.asm
