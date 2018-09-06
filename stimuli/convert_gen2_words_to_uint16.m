files = dir('/Users/maxlab/Desktop/VT_Training/2_Gen_2/nonsense/vt/*.mat');
event = {files.name};

for e=1:length(event)
    load(['/Users/maxlab/Desktop/VT_Training/2_Gen_2/nonsense/vt/' event{e}]);
    rawData = gen2ConvertGesture(eventFile);
    save(['/Users/maxlab/Desktop/VT_Training/2_Gen_2/nonsense/vt_raw/' event{e}], 'rawData');
end

    
