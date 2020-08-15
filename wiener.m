close all;
clear all;
clc;

%% estimation by modelling - blind deconvolution
f=imread('good_latent.bmp'); % image to be degraded 
figure,imshow(f,[]);
title('Original Image');
constant=0.000025;
[M,N]=size(f);

%% Contrast-Limited Adaptive Histogram Equalization (CLAHE)

f=adapthisteq(f);
figure,imshow(f,[]);
title('CLAHE');


%%
%for i=0:255
%    h(i+1)=sum(sum(f==i)); %Frequency of each pixel from 1-256
%end

%y=f; % initialize output image
%s=sum(h); % Total number of pixels
%for i=0:255
%    I=find(f==i); %index of pixels in input image with value �i�
%    y(I)=(255-1)*(sum(h(1:i))/s); %(L-1)*CDF
%end

%for i=0:255
%    hy(i+1)=sum(sum(round(y)==i)); %hist of output
%end

%f=y;

%%
for k =0:767
    for l = 0:799
        H(k+1,l+1)=exp(-constant*(k^1+l^1)^(5/6));  % atmospheric turbulence
    end
end

G=H.*fft2(f); % blurring
g=real(ifft2(G)); %spatial domain
figure,imshow(g,[]);
title('Degraded Image without noise');

%% AWGN
%g=uint8(g)+uint8(30*randn(768,800));   % get h*f + n = HF + N
%G=fft2(g);  % FFT to get Fourier of observed image
%figure,imshow(g,[]); % Show observed image
%title('Degraded Image with noise');

%%  Degraded image
mse=mean(mean((double(g)-double(f)).^2));
snrdegraded=20*log10(255/(sqrt(mse))); % SNR degraded

%%  Laplacian for smothness
l(1,1)=-8; l(2,1)=1; l(1,2)=1; % Center is at (1,1)
l(M,1)=1; l(1,N)=1; % Indices modulo P or Q
l(M,2)=1; l(2,N)=1; l(2,2)=1; l(M,N)=1;

L=fft2(l); %%% for constrained filtering

%% Wiener Filter
lambda=0.01;
C=0.001:.04:4;
err=zeros(1,length(C));
for i=1:length(C)
    F=conj(H).*G./(abs(H).^2+C(i)+((lambda*abs(L).^2).*(C(i)+abs(H).^2)));
    fim=real(ifft2(F));
    err(i)=mean(mean((fim-double(f)).^2));
end

%% Show best restored Wiener
[val,indW]=min(err);
F=conj(H).*G./(abs(H).^2+indW+((lambda*abs(L).^2).*(indW+abs(H).^2)));
fim=real(ifft2(F)); % best restored image
figure,imshow(fim,[]);
title('Best Wiener restored');
snrwiener=20*log10(255/(sqrt(min(err))));  % SNR for restored


%% Opening

se=strel('line',7,45);
%% After Binarization

[r,c]=size(fim);
fim=fim/256;
final=zeros([r,c]);

threshold=0.15;

for i=1:r
    for j=1:c
        if(fim(i,j)>threshold)
            final(i,j)=1;
        else
            final(i,j)=0;
        end 
    end
end

figure,imshow(uint8(final),[]);
title('Wiener after Binarization');

%% Opening

se=strel('line',7,45);

afterOpening=imopen(final,se);
figure,imshow(afterOpening,[]);
title("After Opening");


%% Closing

go=[0 1 0
    1 0 1
    0 1 0];

closeBW=imclose(afterOpening,go);
figure,imshow(closeBW);
title("Opening followed by Closing");
imwrite(closeBW,'Opening_followed_by_Closing.jpg');

