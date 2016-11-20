all: decomposition

run: decomposition
	./decomposition ../res/lena.ppm 2

decomposition: decomposition.o ImageBase.o
	g++ -o decomposition decomposition.o ImageBase.o

decomposition.o: decomposition.cpp ImageBase.h
	g++ -c decomposition.cpp

ImageBase.o: ImageBase.cpp ImageBase.h image_ppm.h
	g++ -c ImageBase.cpp

clean:
	rm -f *.o *~ decomposition
