% Author: Martha Ryan  Date: 4/19-23/2022  Coding Language: Matlab R2021b
% Purpose: Generate slope, R^2, and P-values from linear regression models between precipitaion and edge of field (EOF) runoff datasets.
% Acknowledgements: (1) EOF data was provided by Dr. Yao Hu from the University of Delaware's Department of Geography and Spatial Science. (2) Precipitation datasets    % were provided by the Midwestern Regional Climate Center (https://mrcc.purdue.edu/cliwatch/northAmerPcpn/getArchive.jsp). 


%% Load Site Keys (SK) 

% There should be a SK for every year that's being analyzed. Since I am
% analyzing 2010-2013, there are 4 SK's.
sk1 = readtable('.csv');
sk2 = readtable('.csv');
sk3 = readtable('.csv');
sk4 = readtable('.csv');

%% Convert Site Keys into Lat/Lon and Datetime arrays
latlon1 = table2array(sk1(:,8:9));
latlon2 = table2array(sk2(:,8:9));
latlon3 = table2array(sk3(:,8:9));
latlon4 = table2array(sk4(:,8:9));

datetime1 = table2array(sk1(:,10:11));
datetime2 = table2array(sk1(:,10:11));
datetime3 = table2array(sk1(:,10:11));
datetime4 = table2array(sk1(:,10:11));

%% Extract the EOF Runoff data

% Specify the folders that hold the EOF files. There should be a folder for
% every year.
myFolder1 = '';
myFolder2 = '';
myFolder3 = '';
myFolder4 = '';

% Create empty arrays that will hold the Runoff data.
runOff1 = [];
runOff2 = [];
runOff3 = [];
runOff4 = [];

% Get a list of all files in the first folder with the desired file name
% pattern.
filePattern1 = fullfile(myFolder1,'*.csv'); 
theFiles1 = dir(filePattern1);
for a = 1 : length(theFiles1)
    baseFileName1 = theFiles1(a).name;
    fullFileName1 = fullfile(theFiles1(a).folder, baseFileName1);

    % The file name is saved in the fullFileName variable. Load the file as
    % as a table and convert it into appropriate arrays.  
    EOF1 = readtable(fullFileName1);
    ogDateEOF1 = table2array(EOF1(:,1));
    ogRunOff1 = table2array(EOF1(:,2));
    
    % Find the rows that hold the runoff data in the appropriate year
    superset1 = datetime(ogDateEOF1);
    subset1 = [datenum(0010, 1, 1);datenum(0010, 12, 31)];
    indices1 = datefind(subset1,superset1);
    
    % Create a new array with only the runoff from the rows listed above.
    % Add that array to the final runoff array.
    placeHolder1 = ogRunOff1(indices1(1,1):indices1(2,1),1);
    runOff1 = [runOff1,placeHolder1];
end

% The loop above was for the first year, 2010. This loop is for the next
% consecutive year, 2011. The two loops below follow the same pattern.
filePattern2 = fullfile(myFolder2, '*.csv'); 
theFiles2 = dir(filePattern2);
for b = 1 : length(theFiles2)
    baseFileName2 = theFiles2(b).name;
    fullFileName2 = fullfile(theFiles2(b).folder, baseFileName2);
    EOF2 = readtable(fullFileName2);
    ogDateEOF2 = table2array(EOF2(:,1));
    ogRunOff2 = table2array(EOF2(:,2));
    superset2 = datetime(ogDateEOF2);
    subset2 = [datenum(0011, 1, 1);datenum(0011, 12, 31)];
    indices2 = datefind(subset2,superset2);
    placeHolder2 = ogRunOff2(indices2(1,1):indices2(2,1),1);
    runOff2 = [runOff2,placeHolder2];    
end

% 2012
filePattern3 = fullfile(myFolder3, '*.csv'); 
theFiles3 = dir(filePattern3);
for c = 1 : length(theFiles3)
    baseFileName3 = theFiles3(c).name;
    fullFileName3 = fullfile(theFiles3(c).folder, baseFileName3); 
    EOF3 = readtable(fullFileName3);
    ogDateEOF3 = table2array(EOF3(:,1));
    ogRunOff3 = table2array(EOF3(:,2));
    superset3 = datetime(ogDateEOF3);
    subset3 = [datenum(0012, 1, 1);datenum(0012, 12, 31)];
    indices3 = datefind(subset3,superset3);
    placeHolder3 = ogRunOff3(indices3(1,1):indices3(2,1),1);
    runOff3 = [runOff3,placeHolder3];   
end

% 2013
filePattern4 = fullfile(myFolder4, '*.csv'); 
theFiles4 = dir(filePattern4);
for d = 1 : length(theFiles4)
    baseFileName4 = theFiles4(d).name;
    fullFileName4 = fullfile(theFiles4(d).folder, baseFileName4); 
    EOF4 = readtable(fullFileName4);
    ogDateEOF4 = table2array(EOF4(:,1));
    ogRunOff4 = table2array(EOF4(:,2));
    superset4 = datetime(ogDateEOF4);
    subset4 = [datenum(0013, 1, 1);datenum(0013, 12, 31)];
    indices4 = datefind(subset4,superset4);
    placeHolder4 = ogRunOff4(indices4(1,1):indices4(2,1),1);
    runOff4 = [runOff4,placeHolder4];
end

%% Extract the Precipitation data

% Specify the folders that hold the files. There should be a folder for
% every year.
myFolder1 = '';
myFolder2 = '';
myFolder3 = '';
myFolder4 = '';

% Create empty arrays that will hold the Precipitation data.
precip1 = [];
precip2 = [];
precip3 = [];
precip4 = [];

% Get a list of all files in the first folder with the desired file name 
% pattern.
filePattern1 = fullfile(myFolder1, '*.csv'); 
theFiles1 = dir(filePattern1);
for e = 1 : length(theFiles1)
    baseFileName1 = theFiles1(e).name;
    fullFileName1 = fullfile(theFiles1(e).folder, baseFileName1);

    % The file name is saved in the fullFileName variable. Load the file as
    % as a table and convert it into an appropriate array.  
    CaPA1 = table2array(readtable(fullFileName1));

    % Create an array to hold the precipitation data for each day for every
    % site. This array will be iteratively added to the yearly precip
    % array.
    dailyPrecip1 = [];
    
    % Create a loop to find the precipitation for each site in every file.
    for f = 1:size(latlon1,1)

        % Find the row in the CaPA file w/ the same lat/lon as the site
        % key.  
        [row1,col] = find((CaPA1(:,1)==latlon1(f,1)) & (CaPA1(:,2)==latlon1(f,2)));
       
        % Sometimes, data from certain lat/lons are missing. Determine
        % whether a value was present. 
        TF1 = isempty(row1);

        % If a value was not present, add NaN to the daily precip array.
        % Otherwise, add the precipitation value from the appropriate row. 
        if TF1 == 1
            dailyPrecip1 = [dailyPrecip1,NaN];
        else
            dailyPrecip1 = [dailyPrecip1,CaPA1(row1,3)];
        end
    end
    % Add the daily precipitation array to the yearly precipiation array.
    precip1 = [precip1;dailyPrecip1];
end

% The loop above was for the first year, 2010. This loop is for the next
% consecutive year, 2011. The two loops below follow the same pattern.
filePattern2 = fullfile(myFolder2, '*.csv'); 
theFiles2 = dir(filePattern2);
for g = 1 : length(theFiles2)
    baseFileName2 = theFiles2(g).name;
    fullFileName2 = fullfile(theFiles2(g).folder, baseFileName2); 
    CaPA2 = table2array(readtable(fullFileName2));
    dailyPrecip2 = [];
    for h = 1:size(latlon2,1)
        [row2,col] = find((CaPA2(:,1)==latlon2(h,1)) & (CaPA2(:,2)==latlon2(h,2)));
        TF2 = isempty(row2);
        if TF2 == 1
            dailyPrecip2 = [dailyPrecip2,NaN];
        else
            dailyPrecip2 = [dailyPrecip2,CaPA2(row2,3)];
        end
    end
    precip2 = [precip2;dailyPrecip2];
end

% 2012
filePattern3 = fullfile(myFolder3, '*.csv'); 
theFiles3 = dir(filePattern3);
for i = 1 : length(theFiles3)
    baseFileName3 = theFiles3(i).name;
    fullFileName3 = fullfile(theFiles3(i).folder, baseFileName3);  
    CaPA3 = table2array(readtable(fullFileName3));
    dailyPrecip3 = [];
    for j = 1:size(latlon3,1)
        [row3,col] = find((CaPA3(:,1)==latlon3(j,1)) & (CaPA3(:,2)==latlon3(j,2)));
        TF3 = isempty(row3);
        if TF3 == 1
            dailyPrecip3 = [dailyPrecip3,NaN];
        else
            dailyPrecip3 = [dailyPrecip3,CaPA3(row3,3)];
        end
    end
    precip3 = [precip3;dailyPrecip3];
end

% 2013
filePattern4 = fullfile(myFolder4, '*.csv'); 
theFiles4 = dir(filePattern4);
for k = 1 : length(theFiles4)
    baseFileName4 = theFiles4(k).name;
    fullFileName4 = fullfile(theFiles4(k).folder, baseFileName4); 
    CaPA4 = table2array(readtable(fullFileName4));
    dailyPrecip4 = [];
    for L = 1:size(latlon4,1)
        [row4,col] = find((CaPA4(:,1)==latlon4(L,1)) & (CaPA4(:,2)==latlon4(L,2)));
        TF4 = isempty(row4);
        if TF4 == 1
            dailyPrecip4 = [dailyPrecip4,NaN];
        else
            dailyPrecip4 = [dailyPrecip4,CaPA4(row4,3)];
        end
    end
    precip4 = [precip4;dailyPrecip4];
end

%% Export the cleaned Runoff and Precipitation data

% Convert the runoff and precipitation arrays into tables.
siteData1 = table(runOff1,precip1);
siteData2 = table(runOff2,precip2);
siteData3 = table(runOff3,precip3);
siteData4 = table(runOff4,precip4);

% Export the tables above to the listed CSV files.
writetable(siteData1,'.csv');
writetable(siteData2,'.csv');
writetable(siteData3,'.csv');
writetable(siteData4,'.csv');

%% Create Linear Regressions from Runoff and Precipitation data

% Create empty arrays that will hold the slope, R^2, and P-values from the 
% linear regressions. 
correlation1 = [];
correlation2 = [];
correlation3 = [];
correlation4 = [];

% Loop creates linear regression and records aforementioned values for each
% site being analyzed within a year. 
for m = 1:size(runOff1,2)
    md1 = fitlm(precip1(:,m),runOff1(:,m));
    correlation1 = [correlation1;table2array(md1.Coefficients(2,1)),...
        md1.Rsquared.Ordinary,md1.Coefficients.pValue(2,1)];
end

% 2011
for n = 1:size(runOff2,2)
    md2 = fitlm(precip2(:,n),runOff2(:,n));
    correlation2 = [correlation2;table2array(md2.Coefficients(2,1)),...
        md2.Rsquared.Ordinary,md2.Coefficients.pValue(2,1)];
end

%2012
for o = 1:size(runOff3,2)
    md3 = fitlm(precip3(:,o),runOff3(:,o));
    correlation3 = [correlation3;table2array(md3.Coefficients(2,1)),...
        md3.Rsquared.Ordinary,md3.Coefficients.pValue(2,1)];
end

%2013
for p = 1:size(runOff4,2)
    md4 = fitlm(precip4(:,p),runOff4(:,p));
    correlation4 = [correlation4;table2array(md4.Coefficients(2,1)),...
        md4.Rsquared.Ordinary,md4.Coefficients.pValue(2,1)];
end

%% Export Linear Regression Values

% Convert correlation arrays into tables, and export to listed CSV files.
writetable(table(correlation1),'.csv');
writetable(table(correlation2),'.csv');
writetable(table(correlation3),'.csv');
writetable(table(correlation4),'.csv');