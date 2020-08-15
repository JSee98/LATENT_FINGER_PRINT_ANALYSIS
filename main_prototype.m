clear;
close all;
clc;

img = double(imread('bad_latent.bmp'));
figure;
imshow(uint8(img));
title('Input');

%% Histogram Equalized Image

[M,N]=size(img); % get size of image
for i=0:255
    h(i+1)=sum(sum(img==i)); %Frequency of each pixel from 1-256
end
% compute hist equalization
y=uint8(img); % initialize output image
s=sum(h); % Total number of pixels
for i=0:255
    I=find(img==i); %index of pixels in input image with value �i�
    y(I)=(255-1)*(sum(h(1:i))/s); %(L-1)*CDF
end
%plot hist of output image
r = 0:255;
%stem(r,h) %plot hist of input
for i=0:255
    hy(i+1)=sum(sum(round(y)==i)); %hist of output
end
%figure, stem(r,hy) %plot hist of input
img_hist = y;
figure,imshow(uint8(img_hist));
title('HIST_OUT');
img = double(imresize(img_hist, [768,768]));

sigma = 0.7;
alpha = 1.0;
img = locallapfilt(uint8(img), sigma, alpha);
holder = img;
figure;
imshow(uint8(img));
title('LAP+HIST_OUT');

%% Carrying out FFT
k=0.025;
img_fixed = zeros(768);
i_const = i*2*pi;
dim = 4;
for i=1:191
    for j=1:191
        block = img(i*dim:(i*dim)+(dim-1), j*dim:(j*dim)+(dim-1));
        block_fft = fft2(block);
        mag_fft = abs(block_fft);
        block_fixed = block_fft.*((mag_fft).^k);
        block_ifft = ifft2(block_fixed);
        img_fixed(i*dim:(i*dim)+(dim-1), j*dim:(j*dim)+(dim-1)) = block_ifft;
    end
end

figure;
imshow(real(uint8(img_fixed)));
title('FFT_FIXED');

%% Gaussian Filtering Image

img_gaussian = imgaussfilt(real(img_fixed), 0.45);
figure;
imshow(real(uint8(img_gaussian)));
title('GAUSSIAN_FIXED');


I=uint8(img_fixed);
I1=im2double(I);
[IGradX, IGradY, Ismooth]= smoothing(I1);
Iabst=(IGradX)-(IGradY);
[theta]=computeangle(IGradX,IGradY);
[Iabst1]=nonmaximalsupression(Iabst,theta);
Ie=im2uint8(Iabst1);
Tl=140;
Th=180;

Ie1=gradingedges(Ie,Tl,Th);

figure;
%   subplot(1,2,1);imshow(I);title('origional image');
  %subplot(3,3,1);imshow(I);title('origional image');%% OTSU

[counts,x]=imhist(Ie1,6);

T=otsuthresh(counts);
BW=imbinarize(Ie1,T);
figure,imshow(BW)
  %subplot(3,3,2);imshow(Ismooth);title('Smoothed image');
  figure;imshow(IGradX,[]);title('Gradient along X');
   figure;imshow(IGradY,[]);title('Gradient along Y');
  figure;imshow(Iabst,[]);title('Absolute Gradient');
  figure;imshow(Ie1,[]);title('INonMaximalSupression');
  %subplot(3,3,8);(imshow(Ifinal));title('Final Image');
%   subplot(1,2,2);(imshow(Ifinal));title('Final Image');



i_f = connectingedge(Ie1,Th,Tl);
figure;
imshow(real(uint8(i_f)),[]);
title('fin');

Ie_gaussian = imgaussfilt(real(i_f), 0.85);
figure;
imshow(real(uint8(Ie_gaussian)),[]);
title('gff');

