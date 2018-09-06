piezoDriverGen2('open','/dev/cu.usbmodemFA131');
syll = {'End','Ens','and','ans','ask','da','de','Est','Ets','iht','ik','iks','im','imz','in','is','it','kou',...
    'ma','me','mi','mou','mu','ne','nou','oudz','ounz','oust','outs','ouz','pi','sa','se','snu','spi','spih','sti',...
    'stu','ta','te','ti','tou','tu','ud','un','unz','up','uz'};
for t=1:2
    for c=3:length(syll)
        load(['nonsense/vt_raw/' syll{c} '.mat']);
        rtn_load = piezoDriverGen2('loadGesture',rawData);
        rtn_start = piezoDriverGen2('start');
        rtn_start2 = 0;
        if rtn_start == -1
            rtn_start2 =piezoDriverGen2('start');
        end
        
        WaitSecs(0.5)
        
        [y,fs] = audioread(['nonsense/audio/' syll{c} '.wav']);
        sound(y,fs);
        
        WaitSecs(1)
    end
end
piezoDriverGen2('close');
