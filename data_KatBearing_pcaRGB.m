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
dataPoints = ImageSize; % points from signals
signal_cut_1 = zeros(Samples,ImageSize);
signal_cut_2 = zeros(Samples,ImageSize);
signal_cut_3 = zeros(Samples,ImageSize);
OPERATING = ["N15_M07_F10","N09_M07_F10","N15_M01_F10","N15_M07_F04"];
FILES = ["Healthy", "Outer", "Inner"];  % healthy, outer ring fault, inner ring fault
output_dir = strcat("toImgs/Kat_",num2str(ImageL),"_pcaRGB/");
%data_dir = "dataset/KAT/";
data_dir = ""; % custom dataset

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

            load(mat_path);
            mat_variable = eval(mat_name);
            length4Khz = 16000;
            length64Khz = length4Khz*16;
            signal_force_raw = (mat_variable.Y(1).Data)';
            signal_current_1_raw = (mat_variable.Y(2).Data)'; 
            signal_current_2_raw = (mat_variable.Y(3).Data)';
            signal_speed_raw = (mat_variable.Y(4).Data)';
            signal_torque_raw = (mat_variable.Y(6).Data)';
            signal_vibration_raw = (mat_variable.Y(7).Data)';
            
            signal_force = signal_force_raw;
            signal_current_1 = signal_current_1_raw(1:length64Khz,:);
            signal_current_2 = signal_current_2_raw(1:length64Khz,:);
            signal_speed = signal_speed_raw(1:length4Khz,:);
            signal_torque = signal_torque_raw;
            signal_vibration = signal_vibration_raw(1:length64Khz,:);
            
            signal_force_re = resample(signal_force,64000,4000);
            signal_force_re = signal_force_re(1:length64Khz,:);
            signal_torque_re = resample(signal_torque,64000,4000);
            signal_torque_re = signal_torque_re(1:length64Khz,:);
            dataRaw = [signal_current_1 signal_current_2 signal_vibration signal_force_re signal_torque_re];

            data = pca_noexplained(dataRaw, 3);
            
            %----------------------------------------------------------------------
            %  Random Sampling, Cut and normalize signal
            %----------------------------------------------------------------------
            if save_flag==true
                randomSerial = round(unifrnd (0, 1, 1, Samples)*((length(data)-dataPoints)));
                for iCut=1:Samples
                    cutIndex = randomSerial(iCut);
                    signalCut1(iCut,:) = normalize255(data((cutIndex+1):(cutIndex+dataPoints),1));
                    signalCut2(iCut,:) = normalize255(data((cutIndex+1):(cutIndex+dataPoints),2));
                    signalCut3(iCut,:) = normalize255(data((cutIndex+1):(cutIndex+dataPoints),3));
                end
                %----------------------------------------------------------------------
                %  Convert signal to images
                %----------------------------------------------------------------------
                for iImage=1:Samples
                    imgPre1 = signalCut1(iImage,:);
                    imgPre2 = signalCut2(iImage,:);
                    imgPre3 = signalCut3(iImage,:);
                    
                    img1 = reshape(imgPre1,sqrt(dataPoints),sqrt(dataPoints));
                    img2 = reshape(imgPre2,sqrt(dataPoints),sqrt(dataPoints));
                    img3 = reshape(imgPre3,sqrt(dataPoints),sqrt(dataPoints));
                    imgRGB = cat(3,img1,img2,img3);
                    
                    output_path_subF = strcat(output_dir, operate_name,'/', file_name, '/');
                    makedir(output_path_subF);
                    
                    
                    image_save_path = strcat(output_path_subF,fault_name,'_',num2str(iImage),'.png');
                    imwrite(uint8(imgRGB), image_save_path);
                end
            end
        end
    end
 
end


process_time = toc;
disp_time = ['Running Time is: ', num2str(process_time), ' s'];
disp(disp_time);
