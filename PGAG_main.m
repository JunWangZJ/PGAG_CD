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

% X_p = imageTodata(X_nor,ps,ss);   
% Y_p = imageTodata(Y_nor,ps,ss);   
% MM = max(size(X_p));
% K =round(MM*adj_rate);
% k = K+1;                                          
% X_p_t = X_p';
% Y_p_t = Y_p';
% 
% %%  相似块搜索
% [idx, distX] = knnsearch(X_p_t,X_p_t,'k',k); 
% [idy, distY] = knnsearch(Y_p_t,Y_p_t,'k',k);  
% 
% %%  相似块信息汇聚：相似块的基团被组织成了顶点，进行嵌入。嵌入后，提供自身特征和相似性比较
% % 其中：自身特征由，块均值进行加权求和而成；相似性度量则有块均值序列进行搜索度量而成
% % 工作的核心是以  相似块基团为基础研究单位进行图的构建
% [N,D] = size(X_p_t);
% W_Nx = exp(-(distX.^2)/D);
% W_Ny = exp(-(distY.^2)/D);
% X_agg = zeros(1,N);
% Y_agg = zeros(1,N);
% 
% X_p_m = mean(X_p_t,2)';
% Y_p_m = mean(Y_p_t,2)';
% 
% for ii = 1:N
%     X_agg(ii) = sum(X_p_m(idx(ii,:)).*W_Nx(ii,:))/sum(W_Nx(ii,:));   %  基于自相似原理，中心块可由全图相似块进行加权求和拟合
%     Y_agg(ii) = sum(Y_p_m(idy(ii,:)).*W_Ny(ii,:))/sum(W_Ny(ii,:));   %  这样我们就用相似块的系列来替代原来的像素点  把图像转换成  U*U*N*K （M*N*u*u*K） 的张量  , 然后降维度 块求均值！！
% end
% 
% %%  邻居基团相似性（结构）差异！
% 
% [N,D] = size(X_p_t);
% dows = 4;
% lengds = size(idx(1,1:dows:end),2);   
% 
% Hye_x = zeros(N, lengds);
% Hye_y = zeros(N, lengds);
% 
% for i = 1:N
%     Hye_x(i,:) = mean(X_p_t(idx(i,1:dows:end),:),2);
%     Hye_y(i,:) = mean(Y_p_t(idy(i,1:dows:end),:),2);
% end
% 
% [Hye_idx, Hye_distX] = knnsearch(Hye_x,Hye_x,'k',round(k)); 
% [Hye_idy, Hye_distY] = knnsearch(Hye_y,Hye_y,'k',round(k));  
% 
% [NN,DD] = size(Hye_x);
% 
% Hye_distX_sq = exp(-(Hye_distX.^2)/DD);  % 权重矩阵
% Hye_distY_sq = exp(-(Hye_distY.^2)/DD);
% 
% W_x_he = mean(Hye_distX_sq, 2);   % 权重均值
% W_y_he = mean(Hye_distY_sq, 2);
% 
% hdi_x_y = zeros(size(Hye_distX_sq));
% hdi_y_x = zeros(size(Hye_distX_sq));
% fprintf('高阶结构一致性：');
% 
% for i = 1:NN
%     hdi_x_y(i,:) = exp(-(pdist2(Hye_x(Hye_idy(i,:),:),Hye_x(i,:)).^2)/DD);
%     hdi_y_x(i,:) = exp(-(pdist2(Hye_y(Hye_idx(i,:),:),Hye_y(i,:)).^2)/DD);
%     if mod(i, 10000)==0
%         fprintf('循环次数: %d\n', i);
%     end
% end
% 
% W_mx_he = mean(hdi_x_y,2);
% W_my_he = mean(hdi_y_x,2);
% 
% hfx_dist =  abs(W_x_he - W_mx_he );
% hfy_dist =  abs(W_y_he - W_my_he );
% 
% hf2_dist = (hfx_dist + hfy_dist)/2;
% hf2_dist_i  = dataToimage(hf2_dist,ps,ss,X_nor);
% [m,n] = size(hf2_dist_i);
% DI_he = hf2_dist_i(ps+1:m-ps, ps+1:n-ps);   % 结构差异
% DI_he = DI_he./max(DI_he(:));
% figure,imshow(DI_he);
% 
% %%  邻居基团特征差异！
% X_Nagg = zeros(size(X_agg));
% Y_Nagg = zeros(size(X_agg));
% % 窗口属性传播
% 
% for g_i = 1:N
%     X_Nagg(g_i) = sum(X_agg(Hye_idx(g_i,:)).*Hye_distX_sq(g_i,:))/sum(Hye_distX_sq(g_i,:));
%     Y_Nagg(g_i) = sum(Y_agg(Hye_idy(g_i,:)).*Hye_distY_sq(g_i,:))/sum(Hye_distY_sq(g_i,:));
% end
% 
% for g_i = 1:N
%     X_Nagg(g_i) = sum(X_Nagg(Hye_idx(g_i,:)).*Hye_distX_sq(g_i,:))/sum(Hye_distX_sq(g_i,:));
%     Y_Nagg(g_i) = sum(Y_Nagg(Hye_idy(g_i,:)).*Hye_distY_sq(g_i,:))/sum(Hye_distY_sq(g_i,:));
% end
% 
% X_n = image_normlized(X_Nagg,'sar');
% Y_n = image_normlized(Y_Nagg,'sar');
% f_g = abs(X_n-Y_n);
% 
% DI_subg = dataToimage(f_g,ps,ss,X_nor);
% [m,n] = size(DI_subg);
% DI_g = DI_subg(ps+1:m-ps, ps+1:n-ps);
% DI_g = DI_g./max(DI_g(:));
% figure, imshow(DI_g);

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

% save(dataName + "" + '_ROC_NSG.mat', 'ROC_NSG');
% save(dataName + "" + '_PRC_NSG.mat', 'PRC_NSG');
% filename_DI = sprintf(dataName + "" + '_DI_NSG.png'); 
% filename_PC = sprintf(dataName + "" + '_PC_NSG.png'); 
% imwrite(DI, filename_DI);
% imwrite(rgbImage, filename_PC);
% imwrite(CM_map_OTSU, filename_OTSU);
% imwrite(CM_map_METP, filename_METP);