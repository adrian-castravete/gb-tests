OUTPUT_NAME=gbstacker
CART_NAME=GB Stacker

OBJECT_FILES=$(OUTPUT_NAME).obj

all: build

clean:
	rm -rf *.obj $(OUTPUT_NAME).gbc

build: $(OBJECT_FILES)
	rgblink -t -o $(OUTPUT_NAME).gbc $(OBJECT_FILES)
	rgbfix -v -c -p 0 -t "$(CART_NAME)" $(OUTPUT_NAME).gbc

gambuild: build
	gambatte_qt $(OUTPUT_NAME).gbc

bgbuild: build
	wine ~/Programe/bgb/bgb.exe $(OUTPUT_NAME).gbc

%.obj: %.asm
	rgbasm -o $@ $<
