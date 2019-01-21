all: build

clean:
	rm -rf *.obj hellow.gbc

build: Linkfile hellow.obj
	wlalink -dvr Linkfile hellow.gbc

hellow.obj: hellow.asm
	wla-gb -vo hellow.asm hellow.obj
