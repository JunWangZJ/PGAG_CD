clc;
close all;
clear all;

%% 1-data input
addpath(genpath(pwd));

dataName = 'HD';
X = imread(dataName+ "" + '1.png');
Y = imread(dataName+ "" + '2.png');
Ref_gt = imread(dataName+ "" + '3.png');
ref=Ref_gt(:,:,1);

X_nor = image_normlized(X(:,:,1),'sar');
Y_nor = image_normlized(Y(:,:,1),'sar');
clear X Y;
%% Parameter setting
% With different parameter settings, the results will be a little different
adj_rate = 0.01; %
ps = 2;   % patch_size
ss = 2;    % step
tic,

[DI_g, DI_e] = PGAG(X_nor, Y_nor, adj_rate, ps, ss);

%% DI generation 
DI =   DI_e+DI_g ;
DI = DI./max(DI(:));
figure, imshow(DI);
indexedImage = gray2ind(uint8(DI*255), 256); 
rgbImage = ind2rgb(indexedImage, jet(256)); 
imshow(rgbImage);

%% Otsu
level=graythresh(DI);
CM_OTSU = im2bw(DI, level);
TimeCT = toc;
%% indicator analysis
ref = ref/max(ref(:));

[PRE, REC] = PR_plot(DI,ref,500);
[TPR, FPR]= Roc_plot(DI,ref, 500);
[AUC,~] = AUC_Diagdistance(TPR, FPR);
[AUP, ~] = AUP_Diagdistance(PRE, REC);

ROC_NSG = [FPR; TPR];
PRC_NSG = [REC, PRE];
% figure; plot(FPR,TPR);title('ROC curves'); 
% figure; plot(REC,PRE);title('PR curves');

[tp,fp,tn,fn,fplv,fnlv,~,~,pcc,kappa,imw]=performance(CM_OTSU,1*ref);
F1 = 2*tp/(2*tp + fp + fn);

[FP_x, FP_y] = find(imw==0);
[FN_x, FN_y] = find(imw==255);
CM_map_OTSU(:,:,1) = uint8(CM_OTSU)*255;
CM_map_OTSU(:,:,2) = uint8(CM_OTSU)*255;
CM_map_OTSU(:,:,3) = uint8(CM_OTSU)*255;
for i = 1 : max(size(FP_x))
    CM_map_OTSU(FP_x(i), FP_y(i), 1:3) = [255 0 0];
end
for i = 1 : max(size(FN_x))
    CM_map_OTSU(FN_x(i), FN_y(i), 1:3) = [0 255 0];
end

filename_OTSU = sprintf(dataName + "" + '_OTSU_NSG_FN is %d; FP is %d; AUC is %4.4f; AUP is %4.4f;  PCC is %4.4f; F1 is %4.4f; KC is %4.4f.png',   fn, fp, AUC, AUP, pcc, F1, kappa)

%% MTEP

ii=1;
for i_oa = 0 : 0.001 : 1
    CM_METP = im2bw(DI, i_oa); 
    [~,~,~,~,~,~,~,~,OA_id(ii),~,~]  = performance(CM_METP,1*ref);
    ii=ii+1;
end
id_oa = min(find(OA_id==max(OA_id))*0.001);

CM_METP_f = im2bw(DI, id_oa); 
[tp,fp,tn,fn,fplv,fnlv,~,~,pcc,kappa,imw]=performance(CM_METP_f,1*ref);
F1 = 2*tp/(2*tp + fp + fn);

[FP_x, FP_y] = find(imw==0);
[FN_x, FN_y] = find(imw==255);
CM_map_METP(:,:,1) = uint8(CM_METP_f)*255;
CM_map_METP(:,:,2) = uint8(CM_METP_f)*255;
CM_map_METP(:,:,3) = uint8(CM_METP_f)*255;
for i = 1 : max(size(FP_x))
    CM_map_METP(FP_x(i), FP_y(i), 1:3) = [255 0 0];
end
for i = 1 : max(size(FN_x))
    CM_map_METP(FN_x(i), FN_y(i), 1:3) = [0 255 0];
end
figure,imshow(CM_map_METP);
filename_METP = sprintf(dataName + "" + '_METP_NSG_%4.2fs_FN is %d; FP is %d; AUC is %4.4f; AUP is %4.4f; PCC is %4.4f; F1 is %4.4f; KC is %4.4f.png',  TimeCT, fn, fp, AUC, AUP,  pcc, F1, kappa)

