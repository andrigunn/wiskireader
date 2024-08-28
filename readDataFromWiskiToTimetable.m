function WData = readDataFromWiskiToTimetable(ts_id2read)

clear T tsn ts S time value WData
if isunix
    api = 'http://lvvmwiski.lv.is:8080/KiWIS/KiWIS?service=kisters&type=queryServices&request=getTimeseriesValues&datasource=0';
else
    api = 'http://lvvmwiski:8080/KiWIS/KiWIS?service=kisters&type=queryServices&request=getTimeseriesValues&datasource=0';
end
disp('Reading data from Wiski')
%api = 'http://lvvmwiski:8080/KiWIS/KiWIS?service=kisters&type=queryServices&request=getTimeseriesValues&datasource=0';
disp('Reading data from Wiski')
%ts_id2read = [18234042,6261042,12737042,18114042,6441042];
% Ids from Wiski to read
% BLA/BLA-0LNA10/ResVol/Day.Mean - 45865042
% HAG/HAG-0LNA11/ResVol/Day.Mean - 5973042
% TVM/TVM-0LNA12/ResVol/Day.Mean - 6127042
% BLA/BLA0LPC10/Q/Day.Mean - 47174042
% KAR/200711010001/QCalc/Day.Mean - 61674042
% VAF/200310200001/QCalc/Day.Mean - 63998042
% KAR/KARKBOLNA10/ResLVL/Day.Mean.Abs - 71218042
% Þjórsá Dynkur - 6441042
% Tungnaá Maríufoss - 6261042
% TVM/TVM-0LNA12/ResVol/Day.Mean - 6127042
% IRA/V271/Q/Day.Mean - 60049042
% KAR/200906100000/ResVol/Day.Mean - 11601042
% KAR/200809110006/QCalc/Day.Mean - 18204042
% KAR/KKT.3.LN/Q/Day.Mean - 47334042
% KAR/LNA20.CG/QCalc/Day.Mean - 37089042
% KAR/200609271030/QCalc/Day.Mean - 12316042
% BLA/199609010000/QCalc/Day.Mean - 36427042
% 36412042
% 20713042
% 63525042
% 45879042
% 16821042

% ts_id2read = [45865042,5973042,...
%     5973042,...
%     6127042,...
%     47174042,...
%     61674042,...
%     63998042,...
%     71218042,...
%     6441042,...
%     6261042,...
%     6127042,...
%     60049042,...
%     11601042,...
%     18204042,...
%     47334042,...
%     37089042,...
%     12316042,...
%     36427042,...
%     36412042,...
%     20713042,...
%     18234042,...
%     6261042,...
%     12737042,...
%     6441042,...
%     63525042,...
%     45879042,...
%     71231042,...
%     16821042,...
%     16837042,...
%     11679042,...
%     16485042,...
%     60009042,...
%     15487042];

clear WData

for tsn = 1:length(ts_id2read)
    clear parameters query site_name value ts time S
    parameters = ['&format=dajson&ts_id=',num2str(ts_id2read(tsn)),'&period=complete&metadata=true&dateformat=yyyy-MM-dd HH:mm:ss'];
    
    parameters = ['&format=dajson&ts_id=',num2str(ts_id2read(tsn)),...
        '&from=1988-10-01&to=',datestr(now,'yyyy-mm-dd'),'&metadata=true&dateformat=yyyy-MM-dd HH:mm:ss'];
    query = [api,parameters];
    
    S = webread(query);
    disp(['Reading data from ', S.station_name, ' ' S.parametertype_name,' ', S.ts_name])
    for i = 1:length(S.data)
        ts = S.data{i};
        time(i) = ts(1);
        
        if isempty(cell2mat(ts(2)))
            value(i) = NaN;
        else
            value(i) = cell2mat(ts(2));
        end
        
    end
    
    % Name from API in webread
    % Name to mapp to time series structure
    site_name = S.station_name;

    site_name = strrep(site_name, ' ', '');
    site_name = strrep(site_name, 'á', 'a');
    site_name = strrep(site_name, 'Á', 'A');
    site_name = strrep(site_name, 'ó', 'o');
    site_name = strrep(site_name, 'ö', 'o');
    site_name = strrep(site_name, 'í', 'i');
    site_name = strrep(site_name, 'þ', 'th');
    site_name = strrep(site_name, 'Þ', 'Th');
    
    site_name = strrep(site_name, 'ð', 'd');
    
    site_name = strrep(site_name, 'Æ', 'Ae');
    site_name = strrep(site_name, 'æ', 'ae');
    
    site_name = strrep(site_name, 'ý', 'y');

    site_name = strrep(site_name, 'ú', 'u');
    site_name = strrep(site_name, 'Ú', 'U');
    site_name = strrep(site_name, '-', '_');

    if tsn>1
        if isfield(WData,site_name)
            site_name = [site_name,S.parametertype_name];
            WData.(string(site_name)) = timetable(value','RowTimes',datetime(time)');
            WData.(string(site_name)).Properties.VariableUnits = string(S.ts_unitsymbol); %
            WData.(string(site_name)).Properties.VariableNames = string(S.parametertype_name);
        else
            WData.(string(site_name)) = timetable(value','RowTimes',datetime(time)');
            WData.(string(site_name)).Properties.VariableUnits = string(S.ts_unitsymbol); %
            WData.(string(site_name)).Properties.VariableNames = string(S.parametertype_name);
        end
    else
        WData.(string(site_name)) = timetable(value','RowTimes',datetime(time)');
        WData.(string(site_name)).Properties.VariableUnits = string(S.ts_unitsymbol); % 
        WData.(string(site_name)).Properties.VariableNames = string(S.parametertype_name);
    end
    
    
    
    switch S.ts_unitsymbol % þarf að bæta við case ef tímaupplausn er ekki dags
        case 'm³/s'
            WData.(string(site_name)).Q_GL = WData.(string(site_name)).(string(S.parametertype_name))*60*60*24/10^6;
    
    end

end