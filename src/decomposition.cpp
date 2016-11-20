/***
 *
 *
 *
 *
 *
 *
 *
 **/
 
 #include <iostream>
 #include <sstream>
 #include <stdio.h>
 #include <math.h>
 
 #include "ImageBase.h"
 
 using namespace std;
 
 int main (int argc, char ** argv) {
    
    char imagename[250];
    int height = 0, width = 0;
    
    int nbOfDecomp;  //Nombre décomposition de l'image originale
    int quality;     //Qualité des images à décomposer
    
    ImageBase imIn;
    
    if (argc != 3) {
        cout << "usage: Image.ppm nbOfDecomposition" << endl;
        return EXIT_FAILURE;
    }
    
    /**---------INIT-----------**/
    sscanf (argv[1], "%s", imagename);
    imIn.load(imagename);
    height = imIn.getHeight();
    width = imIn.getWidth();
    stringstream convert(argv[2]); //, convert_2(argv[3]);
    convert >> nbOfDecomp;
    //convert_2 >> quality;
    
    /**--------YCbCr--------**/
    ImageBase img_Y(width, height, true);
    ImageBase img_Cb(width, height, true);
    ImageBase img_Cr(width, height, true);
    
    //convertion --> YCbCr
    for (int h = 0; h < height; h++) {
        for (int w = 0; w < width; w++) {
            //                                R                          G                            B
            img_Y[h][w]  =  (0.2990 * imIn[h*3][w*3]) + (0.587 * imIn[h*3][w*3+1]) + (0.114 * imIn[h*3][w*3+2]);
            img_Cb[h][w] =  (-0.1687 * imIn[h*3][w*3]) + (-0.3313 * imIn[h*3][w*3+1]) + (0.5 * imIn[h*3][w*3+2]) + 128;
            img_Cr[h][w] =  (0.50000 * imIn[h*3][w*3]) + (-0.4187 * imIn[h*3][w*3+1]) + (-0.0813 * imIn[h*3][w*3+2]) + 128;
        }
    }
    
    char y[20] = "image_Y.pgm", Cb[20] = "image_Cb.pgm", Cr[20] = "image_Cr.pgm";     
    img_Y.save(y);
    img_Cb.save(Cb);
    img_Cr.save(Cr);
    
    //Decomposition
    ImageBase tabOfImages [4];
    tabOfImages [0] = img_Y;
    tabOfImages [1] = ImageBase(width, height, true);
    tabOfImages [2] = ImageBase(width, height, true);
    tabOfImages [3] = ImageBase(width, height, true);
    
    //matrice 
    int coefs[height][height];
    int pas = log(height) / log(nbOfDecomp);
    double score = 0;
    
    for (int i = 0; i < pas ; i++)
        for (int j = 0; j < pas; j++)
            coefs[i][j] = 1;
    
    
    
    for (int loop = 1; loop < nbOfDecomp + 1; loop++) {
        for (int i = 0; i < height; i++) 
            for (int j = 0; j < height; j++)
                tabOfImages[loop][i][j] = tabOfImages[loop-1][i][j];
        
        //(left, top)
        for (int i = 0; i < height; i+=2) 
            for (int j = 0; j < height; j+=2) 
                tabOfImages[loop][i/2][j/2] = (1/4) * (tabOfImages[loop-1][i][j] + tabOfImages[loop-1][i+1][j] + tabOfImages[loop-1][i][j+1] + tabOfImages[loop-1][i+1][j+1]);
                
        //(top, right)
        int half = height / 2;
        for (int i = 0; i < height; i+=2) 
            for (int j = 0; j < height; j+=2) {
                tabOfImages[loop][i/2][half+j/2] = (tabOfImages[loop-1][i][j] - tabOfImages[loop-1][i][j+1])/2 + (tabOfImages[loop-1][i+1][j] - tabOfImages[loop-1][i+1][j+1])/2 + 128;
                if (tabOfImages[loop][i/2][half+j/2] > 128) 
                    tabOfImages[loop][i/2][half+j/2] = 128;
                //...?
               score = 0.8;
               score *= (double)(nbOfDecomp + 4- loop)/(double)(nbOfDecomp + 4);
               coefs[i/2][half+j/2] = score + 1;
            }
        
        //(bottom, left)
        for (int i = 0; i < height; i+=2) 
            for (int j = 0; j < height; j+=2) {
                tabOfImages[loop][half+i/2][j/2] = (tabOfImages[loop-1][i][j] - tabOfImages[loop-1][i+1][j])/2 + (tabOfImages[loop-1][i+1][j] - tabOfImages[loop-1][i+1][j+1])/2 + 128;
                if (tabOfImages[loop][half+i/2][j/2] > 128)
                    tabOfImages[loop][half+i/2][j/2] = 128;
                //...?
                score = 0.8;
                score *= (double)(nbOfDecomp + 4- loop)/(double)(nbOfDecomp + 4);
                coefs[half+i/2][j/2] = score + 1;
            }
            
        
        //(bottom, right)
        for (int i = 0; i < height; i+=2)
            for (int j = 0; j < height; j+=2) {
                tabOfImages[loop][half+i/2][half+j/2] = (tabOfImages[loop-1][i][j] - tabOfImages[loop-1][i][j+1]) - (tabOfImages[loop-1][i+1][j] - tabOfImages[loop-1][i+1][j+1])/2 + 128;
                if (tabOfImages[loop][half+i/2][half+j/2] > 128)
                    tabOfImages[loop][half+i/2][half+j/2] = 128;
                //...?
                score = 0.8;
                score *= (double)(nbOfDecomp + 4- loop)/(double)(nbOfDecomp + 4);
                coefs[half+i/2][half+j/2] = score + 1;
            }
    }
    
    int compt = 0;
    for (int i = 0; i < height; i++)
        for (int j = 0; j < height; j++) {
            if (coefs[i][j] == 0) 
                coefs[i][j] = 1;
            tabOfImages[nbOfDecomp][i][j] = coefs[i][j];
            if (tabOfImages[nbOfDecomp][i][j] < 10)
                compt++;
        }
        
    char result[20] = "result.pgm";
    tabOfImages[nbOfDecomp].save(result);
    
    return EXIT_SUCCESS;
 }
