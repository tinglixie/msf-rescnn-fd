% Multi-Signals-to-RGB-Image for kat dataset 

%% Copyright,(c)2020-2024, Georgia Institute of Technology
%{
Created on:  06/05/2020 00:07

@File: data_KatBearing_pcaRGB.m
@Author：Tingli Xie
@Requirement: MATLAB R2020a
%}
clc;clear;close; % Release all data
addpath(genpath(pwd)); % Add all files to working path
%--------------------------------------------------------------------------
% Initialization Parameters
%--------------------------------------------------------------------------
Samples = 2; 
ImageL = 64; ImageW = ImageL; ImageSize = ImageL * ImageW;
DataPoints = ImageSize; % points from signals
signal_cut_1 = zeros(Samples,ImageSize);
signal_cut_2 = zeros(Samples,ImageSize);
signal_cut_3 = zeros(Samples,ImageSize);
OPERATING = ["N15_M07_F10","N09_M07_F10","N15_M01_F10","N15_M07_F04"];
FILES = ["Healthy", "Outer", "Inner"];  % healthy, outer ring fault, inner ring fault
output_dir = strcat("toImgs/Kat_",num2str(ImageL),"_pcaRGB/");
%data_dir = "dataset/KAT/";
%data_dir = ""; % custom dataset

%% Main
tic
save_flag = true; % If save images, set true
for iOperate = 1:numel(OPERATING)
    operate_name = OPERATING(iOperate);
    for iFile= 1:numel(FILES)
        file_name = FILES(iFile);
        switch iFile
            case 1
                FAULT_NAMES = ["K001","K002","K003","K004","K005"];
            case 2
                FAULT_NAMES = ["KA04","KA15","KA16","KA22","KA30"];
            case 3
                FAULT_NAMES = ["KI04","KI14","KI16","KI18","KI21"];
            otherwise
                FAULT_NAMES = [];
        end
        for iFault = 1: numel(FAULT_NAMES)
            fault_name = FAULT_NAMES(iFault);
            %----------------------------------------------------------------------
            %  Read Mat File
            %----------------------------------------------------------------------
            mat_name = strcat(operate_name,"_",fault_name,"_1"); % only select 1 trails for test
            mat_path = strcat(data_dir,fault_name,'/',mat_name,'.mat');
            load(mat_path)
            mat_variable = eval(mat_name);
            signal_force = (mat_variable.Y(1).Data)';
            signal_current_1 = (mat_variable.Y(2).Data)'; 
            signal_current_2 = (mat_variable.Y(3).Data)';
            signal_speed = (mat_variable.Y(4).Data)';
            signal_torque = (mat_variable.Y(6).Data)';
            signal_vibration_1 = (mat_variable.Y(7).Data)'; 
            data_raw = [signal_current_1 signal_current_2 signal_vibration_1];
            data_pca = pca_noexplained(data_raw, 3);
            data = normalize255(data_pca);
            
            %----------------------------------------------------------------------
            %  Random Sampling, Cut and normalize signal
            %----------------------------------------------------------------------
            if save_flag==true
                randomSerial = round(unifrnd (0, 1, 1, Samples)*((length(data_pca)-DataPoints)));
                for iCut=1:Samples
                    cutIndex = randomSerial(iCut);
                    signal_cut_1(iCut,:) = data((cutIndex+1):(cutIndex+DataPoints),1);
                    signal_cut_2(iCut,:) = data((cutIndex+1):(cutIndex+DataPoints),2);
                    signal_cut_3(iCut,:) = data((cutIndex+1):(cutIndex+DataPoints),3);
                end
                %----------------------------------------------------------------------
                %  Convert signal to images
                %----------------------------------------------------------------------
                for iImage=1:Samples
                    image_1_pre = signal_cut_1(iImage,:);
                    image_2_pre = signal_cut_2(iImage,:);
                    image_3_pre = signal_cut_3(iImage,:);
                    
                    image_1_pre_reshape = reshape(image_1_pre,ImageL,ImageW);
                    image_2_pre_reshape = reshape(image_2_pre,ImageL,ImageW);
                    image_3_pre_reshape = reshape(image_3_pre,ImageL,ImageW);
                    image_fusion = cat(3,image_1_pre_reshape,image_2_pre_reshape,image_3_pre_reshape);
                    
                    %output_path_subF = strcat(output_dir,num2str(iOperate-1),'_', operate_name,'/', file_name, '/');
                    output_path_subF = strcat(output_dir, operate_name,'/', file_name, '/');
                    makedir(output_path_subF);
                    
                    
                    image_save_path = strcat(output_path_subF,fault_name,'_',num2str(iImage),'.png');
                    imwrite(uint8(image_fusion), image_save_path);
                end
            end
        end
    end
 
end


process_time = toc;
disp_time = ['Running Time is: ', num2str(process_time), ' s'];
disp(disp_time);
