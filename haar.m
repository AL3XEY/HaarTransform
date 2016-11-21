close all;
clear all;
clc;

pkg load image;

n = 1; %1 ~ 6

%imgRgb = imread('res/lena.ppm');
imgRgb = imread('res/peppers.ppm');
%imgRgb = imread('res/trees.ppm');
[h w c] = size(imgRgb);
img = rgb2ycbcr(imgRgb);
%img = imgRgb;
img = int32(img);

%%%%% DWT %%%%%

imgRes = zeros(h,w,c);
q = 50*(2^n);
qs = zeros(h,w,c);
quantified = zeros(h,w,c);
for k=1:n
  for i=1:h/(2^k)
    for j=1:w/(2^k)
      for cc=1:c
        A = img(2*i-1,2*j-1,cc);
        B = img(2*i-1,2*j,cc);
        C = img(2*i,2*j-1,cc);
        D = img(2*i,2*j,cc);
        X = (A + B)/2;
        Y = (C + D)/2;
        K = A - B;
        L = C - D;
        imgRes(i,j,cc) = (X + Y)/2;
        imgRes(i,j+w/(2^k),cc) = (K + L)/2 + 128;
        imgRes(i+h/(2^k),j,cc) = X - Y + 128;
        imgRes(i+h/(2^k),j+w/(2^k),cc) = K - L + 128;

        %quantified(i,j,cc) = imgRes(i,j,cc);
        %quantified(i,j+w/(2^k),cc) = imgRes(i,j+w/(2^k),cc)-128 / (q/2);
        %quantified(i+h/(2^k),j,cc) = imgRes(i+h/(2^k),j,cc)-128 / (q/2);
        %quantified(i+h/(2^k),j+w/(2^k),cc) = imgRes(i+h/(2^k),j+w/(2^k),cc)-128 / q;

        quantified(i,j,cc) = imgRes(i,j,cc);
        quantified(i,j+w/(2^k),cc) = imgRes(i,j+w/(2^k),cc) / (q/2);
        quantified(i+h/(2^k),j,cc) = imgRes(i+h/(2^k),j,cc) / (q/2);
        quantified(i+h/(2^k),j+w/(2^k),cc) = imgRes(i+h/(2^k),j+w/(2^k),cc) / q;

        qs(i,j,cc) = 1;
        qs(i,j+w/(2^k),cc) = q/2;
        qs(i+h/(2^k),j,cc) = q/2;
        qs(i+h/(2^k),j+w/(2^k),cc) = q;

      end
    end
  end
  img = imgRes;
  q = q/2;
end
min(min(min(imgRes)))
max(max(max(imgRes)))
imgRes = uint8(imgRes);
%OR, for results between 0 and 1
%imgRes(:,:,1) = mat2gray(imgRes(:,:,1));
%imgRes(:,:,2) = mat2gray(imgRes(:,:,2));
%imgRes(:,:,3) = mat2gray(imgRes(:,:,3));

figure(1);
imshow(imgRgb);
figure(2);
imshow(imgRes(:,:,1));
%figure(3);
%imshow(imgRes(:,:,2));
%figure(4);
%imshow(imgRes(:,:,3));

%%%%% Quantification %%%%%

quantified = floor(quantified);
%colormap jet;
%figure(5)
%imagesc(quantified(:,:,1));
%figure(6)
%imagesc(quantified(:,:,2));
%figure(7)
%imagesc(quantified(:,:,3));

max(max(max(quantified)))
min(min(min(quantified)))

%%%%% Image reconstruction %%%%%

imgRecTmp = zeros(h,w,c);
imgRec = quantified.*qs;
figure(40);
imshow(ycbcr2rgb(uint8(quantified)));

%TODO
for k=n:-1:1
  for i=1:h/(2^k)
    for j=1:w/(2^k)
      for cc=1:c
%        A = img(2*i-1,2*j-1,cc);
%        B = img(2*i-1,2*j,cc);
%        C = img(2*i,2*j-1,cc);
%        D = img(2*i,2*j,cc);
%        X = (A + B)/2;
%        Y = (C + D)/2;
%        K = A - B;
%        L = C - D;
%        imgRes(i,j,cc) = (X + Y)/2;
%        imgRes(i,j+w/(2^k),cc) = (K + L)/2 + 128;
%        imgRes(i+h/(2^k),j,cc) = X - Y + 128;
%        imgRes(i+h/(2^k),j+w/(2^k),cc) = K - L + 128;
        imgRecTmp(2*i-1,2*j-1,cc) = imgRec(i,j,cc);

        %imgRecTmp(2*i-1,2*j,cc) = imgRec(i,j,cc) + imgRec(i,j+w/(2^k),cc);
        imgRecTmp(2*i-1,2*j,cc) = (imgRec(i,j,cc) + imgRec(i,j+w/(2^k),cc))/2;
        %imgRecTmp(2*i-1,2*j,cc) = imgRec(i,j+w/(2^k),cc);
        %imgRec(i,j+w/(2^k),cc)
        %%imgRecTmp(2*i-1,2*j,cc) = imgRec(i,j+w/(2^k),cc) + 128;

        %imgRecTmp(2*i,2*j-1,cc) = imgRec(i,j,cc) + imgRec(i+h/(2^k),j,cc);
        imgRecTmp(2*i,2*j-1,cc) = (imgRec(i,j,cc) + imgRec(i+h/(2^k),j,cc))/2;
        %imgRecTmp(2*i,2*j-1,cc) = imgRec(i+h/(2^k),j,cc);
        %%imgRecTmp(2*i,2*j-1,cc) = imgRec(i+h/(2^k),j,cc) + 128;

        %imgRecTmp(2*i,2*j,cc) = imgRec(i,j,cc) + imgRec(i+h/(2^k),j+w/(2^k),cc);
        imgRecTmp(2*i,2*j,cc) = (imgRec(i,j,cc) + imgRec(i+h/(2^k),j+w/(2^k),cc))/2;
        %imgRecTmp(2*i,2*j,cc) = imgRec(i+h/(2^k),j+w/(2^k),cc);
        %%imgRecTmp(2*i,2*j,cc) = imgRec(i+h/(2^k),j+w/(2^k),cc) + 128;

      end
    end
 end
  imgRec = imgRecTmp;
end

imgRec = uint8(imgRec);
imgRec = ycbcr2rgb(imgRec);
figure(8);
imshow(imgRec);
imwrite(imgRec, 'imgRec.ppm');
imwrite(imgRec, 'imgRec.png');

%%%%% bpp/PSNR plot %%%%%

%entropy of images
%psnr(res, imgRgb)
PSNR = psnr(imgRgb, imgRec)
zero = uint8(zeros(h,w,c));
PSNRzero = psnr(imgRgb, zero)
