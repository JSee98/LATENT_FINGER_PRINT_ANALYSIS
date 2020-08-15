function [Ioutput]= cannydetector(I)
%I=imread('x5.bmp');[Ioutput]= cannydetector(I);
close all
I1=im2double(I);
[IGradX, IGradY, Ismooth]= smoothing(I1);
Iabst=abs(IGradX)+abs(IGradY);
[theta]=computeangle(IGradX,IGradY);
[Iabst1]=nonmaximalsupression(Iabst,theta);
Ie=im2uint8(Iabst1);
Tl=145;
Th=180;


[Ie1]=gradingedges(Ie,Tl,Th);
[Ifinal]=connectingedge(Ie1,Tl,Th);
theta=padarray(theta,[1 1]);
Ifinal= Ifinal(7:end-7,7:end-7);
Ioutput=Ifinal;
figure;
%   subplot(1,2,1);imshow(I);title('origional image');
  subplot(3,3,1);imshow(I);title('origional image');
  subplot(3,3,2);imshow(Ismooth);title('Smoothed image');
  subplot(3,3,3);imshow(IGradX);title('Gradient along X');
  subplot(3,3,4);imshow(IGradY);title('Gradient along Y');
  subplot(3,3,5);imshow(Iabst);title('Absolute Gradient');
  subplot(3,3,6);imshow(Ie);title('INonMaximalSupression');
  subplot(3,3,7);imshow(Ie1);title('Threshold hysterisis');
  subplot(3,3,8);(imshow(Ifinal));title('Final Image');
%   subplot(1,2,2);(imshow(Ifinal));title('Final Image');

figure
[H, theta, rho] = hough(Ioutput, 'ThetaRes', .2);
imshow(H, [], 'XData', theta, 'YData', rho )
axis on, axis normal
xlabel('\theta'), ylabel('\rho')
peaks = houghpeaks(H, 8);
hold on
plot(theta(peaks(:, 2)), rho(peaks(:, 1)), ...
'linestyle', 'none', 'marker', 's', 'color', 'W')
lines = houghlines(Ioutput, theta, rho, peaks);
figure, imshow(Ioutput), hold on
for k = 1 :length(lines)
xy = [lines(k) .point1 ; lines(k) .point2];
plot(xy(:,1), xy(:,2), 'LineWidth', 2, 'Color', [.8 .8 .8]);
end
   
   