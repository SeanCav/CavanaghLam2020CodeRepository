function [ p_perm_mean_beta, p_perm_SD_beta, p_perm_pvbindex] = PermTestBetasRatio_Aug2020sc(ChosenTarget_saline,EvidenceUnitsA_saline,EvidenceUnitsB_saline, ...
    ChosenTarget_ket,EvidenceUnitsA_ket,EvidenceUnitsB_ket, ...
    mean_beta_actual_diff, SD_beta_actual_diff, pvb_actual_diff, n_perm)

%% Initialization
n_trials_saline = length(ChosenTarget_saline);                             % Number of Saline trials.
n_trials_ketamine = length(ChosenTarget_ket);                              % Number of Ketamine trials.
range_n_trial_all = 1:(n_trials_saline+n_trials_ketamine);                 % Numbered indices of saline and ketmaine trials.

%Combine the bariables across the two trial types
ChosenTarget_all = [ChosenTarget_saline, ChosenTarget_ket];
EvidenceUnitsA_all = [EvidenceUnitsA_saline; EvidenceUnitsA_ket];
EvidenceUnitsB_all = [EvidenceUnitsB_saline; EvidenceUnitsB_ket];
    
%% Shuffle data and run regression models.
p_perm_mean_beta =0;
p_perm_SD_beta =0;
p_perm_pvbindex =0;

for i_perm = 1:n_perm
    indices_saline = range_n_trial_all(sort(randperm(numel(range_n_trial_all), n_trials_saline)));         % Randomly choose a shuffled subset as saline trials.
    indices_ket = setdiff(range_n_trial_all, indices_saline);                                              % The rest are ketamine trials.
    ChosenTarget_saline_shuffled = ChosenTarget_all(indices_saline);
    EvidenceUnitsA_saline_shuffled = EvidenceUnitsA_all(indices_saline,:);
    EvidenceUnitsB_saline_shuffled = EvidenceUnitsB_all(indices_saline,:);
    ChosenTarget_ket_shuffled = ChosenTarget_all(indices_ket);
    EvidenceUnitsA_ket_shuffled = EvidenceUnitsA_all(indices_ket,:);
    EvidenceUnitsB_ket_shuffled = EvidenceUnitsB_all(indices_ket,:);

    % Run regression model per permutation
      
    [Reg_bars_saline_shuffled, ~] = PvbRegressionAnalysis(EvidenceUnitsA_saline_shuffled, EvidenceUnitsB_saline_shuffled, ChosenTarget_saline_shuffled);
    [Reg_bars_ket_shuffled, ~] = PvbRegressionAnalysis(EvidenceUnitsA_ket_shuffled, EvidenceUnitsB_ket_shuffled, ChosenTarget_ket_shuffled);
 
    mean_beta_ket_saline_diff_shuffled_temp  = Reg_bars_ket_shuffled(2) - Reg_bars_saline_shuffled(2);
    SD_beta_ket_saline_diff_shuffled_temp    = Reg_bars_ket_shuffled(3) - Reg_bars_saline_shuffled(3);
    pvb_ket_saline_diff_shuffled_temp = (Reg_bars_ket_shuffled(3)/Reg_bars_ket_shuffled(2)) - (Reg_bars_saline_shuffled(3)/Reg_bars_saline_shuffled(2));
   
    % Two-tailed test - compares parameters sgenerated by shuffling data to true values  
    if abs(mean_beta_ket_saline_diff_shuffled_temp) > abs(mean_beta_actual_diff)
        p_perm_mean_beta = p_perm_mean_beta + 1/n_perm;
    end
    if abs(SD_beta_ket_saline_diff_shuffled_temp) > abs(SD_beta_actual_diff)
        p_perm_SD_beta = p_perm_SD_beta + 1/n_perm;
    end
    if abs(pvb_ket_saline_diff_shuffled_temp) > abs(pvb_actual_diff)
        p_perm_pvbindex = p_perm_pvbindex + 1/n_perm;
    end
        
PercentComplete = 100*(i_perm/n_perm); %What proportion of the permutations are completed?
if sum(PercentComplete==10:10:100) %Report the output to the command window
    fprintf(['Running PVB permutation test: ' num2str(PercentComplete) ' percent complete \n'])
end
end
end
