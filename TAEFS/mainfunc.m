
clear; clc;


% run test
rng('shuffle','twister');
warning off


for Problems =  [7 31 66] % Vehicle  LSVT 11Tumor
       for i = 1:1
            platemo_grid('algorithm',@TAEFS,'problem',{@MOFS,Problems,2,1},'save',20,'maxFE',100,'runno',i);
      end
end
